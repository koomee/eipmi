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
%%% TODO
%%% @end
%%%=============================================================================
-module(eipmi).

-behaviour(application).
-behaviour(supervisor).

%% API
-export([open/1,
         open/2,
         ping/1,
         ping/2]).

%% Application callbacks
-export([start/2,
         stop/1]).

%% supervisor callbacks
-export([init/1]).

-registered([?MODULE]).

-type auth_type() :: none | md2 | md5 | pwd.

-type privilege_level() :: callback | user | operator | administrator.

-type requestor() :: 16#81..16#8d.

-type options() :: [{user, string()} | %% omitted means null user (User 1)
                    {requestor_addr, requestor()} |
                    {initial_outbound_session_seq_nr, 0..255} |
                    {preferred_auth_type, auth_type()} |
                    {pwd, string()} |
                    {privilege_level, privilege_level()}].

-export_type([auth_type/0, privilege_level/0, requestor/0, options/0]).

-include("eipmi.hrl").

%%%=============================================================================
%%% API
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @doc
%% TODO
%% @end
%%------------------------------------------------------------------------------
-spec open(string()) ->
                  {ok, pid()} | {error, term()}.
open(IPAddress) ->
    open(IPAddress, []).

%%------------------------------------------------------------------------------
%% @doc
%% TODO
%% @end
%%------------------------------------------------------------------------------
-spec open(string(), options()) ->
                  {ok, pid()} | {error, term()}.
open(IPAddress, Options) ->
    DefaultOpts = [{requestor_addr, 16#81},
                   {initial_outbound_session_seq_nr, 0},
                   {preferred_auth_type, none},
                   {privilege_level, administrator}],
    Spec = {{remote_console, IPAddress},
            {eipmi_session, start_link, [IPAddress, Options ++ DefaultOpts]},
            temporary, 2000, worker, [eipmi_session]},
    supervisor:start_child(?MODULE, Spec).

%%------------------------------------------------------------------------------
%% @doc
%% Pings a given host using RMCP ping. This can be done to check a device for
%% the IPMI capability before opening a session to it. Default timeout is 5000
%% milliseconds. Returns `pong' if the pinged host supports IPMI, `pang'
%% otherwise.
%% @see ping/2
%% @end
%%------------------------------------------------------------------------------
-spec ping(string()) ->
                  pang | pong.
ping(IPAddress) ->
    ping(IPAddress, 5000).

%%------------------------------------------------------------------------------
%% @doc
%% Same as {@link ping/1} but allows the specification of a custom timeout value
%% in milliseconds.
%% @end
%%------------------------------------------------------------------------------
-spec ping(string(), timeout()) ->
                  pang | pong.
ping(IPAddress, Timeout) when is_integer(Timeout) andalso Timeout > 0 ->
    {ok, Socket} = gen_udp:open(0, [binary, {active, false}]),
    try do_ping(IPAddress, Timeout div 2, Socket) of
        _ -> pong
    catch
        _:_ -> pang
    after
        gen_udp:close(Socket)
    end.

%%%=============================================================================
%%% Application callbacks
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
start(_StartType, _StartArgs) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
stop(_State) ->
    ok.

%%%=============================================================================
%%% supervisor callbacks
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
init([]) ->
    {ok, {{one_for_one, 0, 1}, []}}.

%%%=============================================================================
%%% internal functions
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
do_ping(IPAddress, Timeout, Socket) ->
    {ok, Ping} = eipmi_messages:encode_packet(#rmcp_ping{seq_nr = 0, asf_tag = 0}),
    ok = gen_udp:send(Socket, IPAddress, ?RMCP_PORT_NUMBER, Ping),
    do_ping_receive(IPAddress, Timeout, Socket).

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
do_ping_receive(IPAddress, Timeout, Socket) ->
    {ok, {_, _, Packet}} = gen_udp:recv(Socket, 8192, Timeout),
    case eipmi_messages:decode_packet(Packet) of
        {ok, #rmcp_ack{}} ->
            do_ping_receive(IPAddress, Timeout, Socket);

        {ok, #rmcp_pong{entities = [ipmi]}} ->
            {ok, Ack} = eipmi_messages:encode_packet(#rmcp_ack{seq_nr = 0}),
            gen_udp:send(Socket, IPAddress, ?RMCP_PORT_NUMBER, Ack),
            ok
    end.
