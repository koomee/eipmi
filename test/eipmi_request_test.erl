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
%%%=============================================================================

-module(eipmi_request_test).

-include_lib("eunit/include/eunit.hrl").

-include("eipmi.hrl").

%%%=============================================================================
%%% TESTS
%%%=============================================================================

encode_get_device_id_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?GET_DEVICE_ID},
    ?assertEqual(<<>>, eipmi_request:encode(Req, [])).

encode_cold_reset_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?COLD_RESET},
    ?assertEqual(<<>>, eipmi_request:encode(Req, [])).

encode_warm_reset_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?WARM_RESET},
    ?assertEqual(<<>>, eipmi_request:encode(Req, [])).

encode_get_device_guid_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?GET_DEVICE_GUID},
    ?assertEqual(<<>>, eipmi_request:encode(Req, [])).

encode_get_system_guid_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?GET_SYSTEM_GUID},
    ?assertEqual(<<>>, eipmi_request:encode(Req, [])).

encode_get_channel_authentication_capabilities_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?GET_CHANNEL_AUTHENTICATION_CAPABILITIES},
    Properties = [{privilege, administrator}],
    ?assertEqual(<<16#0e, 16#04>>, eipmi_request:encode(Req, Properties)).

encode_get_session_challenge_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?GET_SESSION_CHALLENGE},
    Properties = [{auth_type, none}, {user, "hello_world"}],
    ?assertEqual(
       <<16#00, $h, $e, $l, $l, $o, $_, $w, $o, $r, $l, $d,
         16#00, 16#00, 16#00, 16#00, 16#00>>,
       eipmi_request:encode(Req, Properties)).

encode_activate_session_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?ACTIVATE_SESSION},
    Properties = [{auth_type, none},
                  {privilege, administrator},
                  {initial_outbound_seq_nr, 16#11223344},
                  {challenge, <<$h, $e, $l, $l, $o, 16#00, 16#00, 16#00, 16#00,
                                16#00, 16#00, 16#00, 16#00, 16#00, 16#00, 16#00>>}],
    ?assertEqual(
       <<16#00, 16#04, $h, $e, $l, $l, $o, 16#00, 16#00, 16#00, 16#00, 16#00,
         16#00, 16#00, 16#00, 16#00, 16#00, 16#00, 16#44, 16#33, 16#22, 16#11>>,
       eipmi_request:encode(Req, Properties)).

encode_set_session_privilege_level_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?SET_SESSION_PRIVILEGE_LEVEL},
    Properties = [{privilege, administrator}],
    ?assertEqual(<<16#04>>, eipmi_request:encode(Req, Properties)).

encode_close_session_test() ->
    Req = {?IPMI_NETFN_APPLICATION_REQUEST, ?CLOSE_SESSION},
    Properties = [{session_id, 16#11223344}],
    ?assertEqual(
       <<16#44, 16#33, 16#22, 16#11>>,
       eipmi_request:encode(Req, Properties)).
