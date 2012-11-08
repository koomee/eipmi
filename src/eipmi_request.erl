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
%%% A module providing encoding functionality for the data parts of IPMI
%%% requests. This module will need care if support for new requests is
%%% demanded.
%%% @end
%%%=============================================================================

-module(eipmi_request).

-export([encode/2]).

-include("eipmi.hrl").

%%%=============================================================================
%%% API
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @doc
%% Encodes IPMI requests according to the concrete request type. All needed
%% values will be retrieved from the provided property list.
%% @end
%%------------------------------------------------------------------------------
-spec encode(eipmi:request(), proplists:proplist()) ->
                    binary().
encode({?IPMI_NETFN_SENSOR_EVENT_REQUEST, Cmd}, Properties) ->
    encode_sensor_event(Cmd, Properties);
encode({?IPMI_NETFN_APPLICATION_REQUEST, Cmd}, Properties) ->
    encode_application(Cmd, Properties);
encode({?IPMI_NETFN_STORAGE_REQUEST, Cmd}, Properties) ->
    encode_storage(Cmd, Properties);
encode({?IPMI_NETFN_TRANSPORT_REQUEST, Cmd}, Properties) ->
    encode_transport(Cmd, Properties).

%%%=============================================================================
%%% Internal functions
%%%=============================================================================

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
encode_sensor_event(_Cmd, _Properties) ->
    <<>>.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
encode_application(?GET_DEVICE_ID, _Properties) ->
    <<>>;
encode_application(?COLD_RESET, _Properties) ->
    <<>>;
encode_application(?WARM_RESET, _Properties) ->
    <<>>;
encode_application(?GET_SELF_TEST_RESULTS, _Properties) ->
    <<>>;
encode_application(?GET_ACPI_POWER_STATE, _Properties) ->
    <<>>;
encode_application(?GET_DEVICE_GUID, _Properties) ->
    <<>>;
encode_application(?GET_SYSTEM_GUID, _Properties) ->
    <<>>;
encode_application(?GET_CHANNEL_AUTHENTICATION_CAPABILITIES, Properties) ->
    P = encode_privilege(eipmi_util:get_val(privilege, Properties)),
    <<0:1, ?EIPMI_RESERVED:3, ?IPMI_REQUESTED_CHANNEL:4, ?EIPMI_RESERVED:4,P:4>>;
encode_application(?GET_SESSION_CHALLENGE, Properties) ->
    A = eipmi_auth:encode_type(eipmi_util:get_val(auth_type, Properties)),
    U = eipmi_util:normalize(16, eipmi_util:get_val(user, Properties)),
    <<?EIPMI_RESERVED:4, A:4, U/binary>>;
encode_application(?ACTIVATE_SESSION, Properties) ->
    A = eipmi_auth:encode_type(eipmi_util:get_val(auth_type, Properties)),
    P = encode_privilege(eipmi_util:get_val(privilege, Properties)),
    C = eipmi_util:normalize(16, eipmi_util:get_val(challenge, Properties)),
    S = eipmi_util:get_val(initial_outbound_seq_nr, Properties),
    <<?EIPMI_RESERVED:4, A:4, ?EIPMI_RESERVED:4, P:4, C/binary, S:32/little>>;
encode_application(?SET_SESSION_PRIVILEGE_LEVEL, Properties) ->
    P = encode_privilege(eipmi_util:get_val(privilege, Properties)),
    <<?EIPMI_RESERVED:4, P:4>>;
encode_application(?CLOSE_SESSION, Properties) ->
    <<(eipmi_util:get_val(session_id, Properties)):32/little>>.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
encode_storage(?GET_FRU_INVENTORY_AREA_INFO, Properties) ->
    <<(eipmi_util:get_val(fru_id, Properties)):8>>;
encode_storage(?READ_FRU_DATA, Properties) ->
    FruId = eipmi_util:get_val(fru_id, Properties),
    Offset = eipmi_util:get_val(offset, Properties),
    Count = eipmi_util:get_val(count, Properties),
    true = Offset =< 16#ffff,
    <<FruId:8, Offset:16/little, Count:8>>;
encode_storage(?GET_SEL_INFO, _Properties) ->
    <<>>;
encode_storage(?RESERVE_SEL, _Properties) ->
    <<>>;
encode_storage(?GET_SEL_ENTRY, Properties) ->
    Record = eipmi_util:get_val(record_id, Properties),
    true = Record =< 16#ffff,
    <<0:16, Record:16/little, 0:8, 16#ff:8>>;
encode_storage(?CLEAR_SEL, Properties) ->
    Reservation = eipmi_util:get_val(reservation_id, Properties),
    Init = eipmi_util:get_val(initiate, Properties, true),
    InitOrGet = case Init of true -> 16#aa; false -> 0 end,
    <<Reservation:16/little, $C:8, $L:8, $R:8, InitOrGet:8>>;
encode_storage(?GET_SDR_REPOSITORY_INFO, _Properties) ->
    <<>>;
encode_storage(?RESERVE_SDR_REPOSITORY, _Properties) ->
    <<>>;
encode_storage(?GET_SDR, Properties) ->
    Reservation = eipmi_util:get_val(reservation_id, Properties, 16#0000),
    Record = eipmi_util:get_val(record_id, Properties),
    Offset = eipmi_util:get_val(offset, Properties, 16#00),
    Count = eipmi_util:get_val(count, Properties, 16#ff),
    true = Record =< 16#ffff,
    <<Reservation:16/little, Record:16/little, Offset:8, Count:8>>.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
encode_transport(?GET_IP_UDP_RMCP_STATISTICS, Properties) ->
    Clear = eipmi_util:get_val(clear_statistics, Properties, false),
    C = case Clear of true -> 1; false -> 0 end,
    <<?EIPMI_RESERVED:4, ?IPMI_REQUESTED_CHANNEL:4, ?EIPMI_RESERVED:7, C:1>>;
encode_transport(?GET_LAN_CONFIGURATION_PARAMETERS, Properties) ->
    P = eipmi_util:get_val(parameter, Properties),
    S = eipmi_util:get_val(set, Properties, 0),
    B = eipmi_util:get_val(block, Properties, 0),
    <<1:1, ?EIPMI_RESERVED:3, ?IPMI_REQUESTED_CHANNEL:4, P:8, S:8 , B:8>>.

%%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
encode_privilege(present) -> 0;
encode_privilege(callback) -> 1;
encode_privilege(user) -> 2;
encode_privilege(operator) -> 3;
encode_privilege(administrator) -> 4.
