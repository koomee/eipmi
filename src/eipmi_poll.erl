%%%=============================================================================
%%% Copyright (c) 2012 Lindenbaum GmbH
%%%
%%% Permission to use, copy, modify, and/or distribute this software for any
%%% purpose with or without fee is hereby granted, provided that the above
%%% copyright notice and this permission notice appear in all copies.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
%%% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
%%% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
%%%
%%% @doc
%%% A server that periodically polls information for a specific IPMI target.
%%% The server monitors its corresponding {@link eipmi_session} process and
%%% exits as soon as the session gets down.
%%%
%%% Currently only polling of the target's System Event Log (SEL) is supported.
%%% All entries retrieved from the SEL will be forwarded as asynchronous events
%%% to the currently subscribed handlers using {@link eipmi_events}.
%%% @end
%%%=============================================================================
-module(eipmi_poll).

-behaviour(gen_server).

%% API
-export([start_link/4]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-include("eipmi.hrl").

%%------------------------------------------------------------------------------
%% Polling server defaults modifyable by the user.
%%------------------------------------------------------------------------------
-define(DEFAULTS,
        [
         {poll_sel, 500},
         {clear_sel, true}
        ]).

%%%=============================================================================
%%% API
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @doc
%% Start a polling server for the given session process.
%% @end
%%------------------------------------------------------------------------------
-spec start_link(pid(),
                 eipmi:session(),
                 inet:ip_address() | inet:hostname(),
                 [eipmi:option()]) ->
                        {ok, pid()} | {error, term()}.
start_link(SessionPid, Session, IPAddress, Options) ->
    Args = [SessionPid, Session, IPAddress, Options],
    gen_server:start_link(?MODULE, Args, []).

%%%=============================================================================
%%% gen_server Callbacks
%%%=============================================================================

-record(state, {
          pid        :: pid(),
          session    :: eipmi:session(),
          address    :: inet:ip_address() | inet:hostname(),
          properties :: [eipmi:option()]}).

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
init([Pid, S, Addr, Options]) ->
    erlang:monitor(process, Pid),
    Opts = eipmi_util:merge_vals(Options, ?DEFAULTS),
    State = #state{pid = Pid, session = S, address = Addr, properties = Opts},
    {ok, start_timer(poll_sel, State)}.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
handle_call(Request, _From, State) ->
    {reply, undef, fire({unhandled, {call, Request}}, State)}.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
handle_cast(Request, State) ->
    {noreply, fire({unhandled, {cast, Request}}, State)}.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
handle_info({'DOWN', _, process, P, _}, State = #state{pid = P}) ->
    {stop, normal, State};
handle_info(poll_sel, State) ->
    {noreply, start_timer(poll_sel, read_sel(State))};
handle_info(Info, State) ->
    {noreply, fire({unhandled, {info, Info}}, State)}.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
read_sel(State = #state{pid = Pid, properties = Ps}) ->
    case catch eipmi_sel:read(Pid, proplists:get_value(clear_sel, Ps)) of
        Entries when is_list(Entries) ->
            lists:foldl(fun fire/2, State, Entries);
        _ ->
            State
    end.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
start_timer(Message, State = #state{properties = Ps}) ->
    erlang:send_after(proplists:get_value(Message, Ps), self(), Message),
    State.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
fire(Event, State = #state{session = Session, address = Address}) ->
    eipmi_events:fire(Session, Address, Event),
    State.
