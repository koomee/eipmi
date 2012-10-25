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

-module(eipmi_response_test).

-include_lib("eunit/include/eunit.hrl").

-include("eipmi.hrl").

%%%=============================================================================
%%% TESTS
%%%=============================================================================

decode_get_device_id_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?GET_DEVICE_ID},
    Bin = <<16#00, 16#82, 16#02, 16#0d, 16#51, 16#3e, 16#78, 16#6c, 16#00,
            16#03, 16#0b, 16#00, 16#00, 16#00, 16#00>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual(0, eipmi_util:get_val(device_id, Properties)),
    ?assertEqual(2, eipmi_util:get_val(device_revision, Properties)),
    ?assertEqual(normal, eipmi_util:get_val(operation, Properties)),
    ?assertEqual("2.13", eipmi_util:get_val(firmware_version, Properties)),
    ?assertEqual("1.5", eipmi_util:get_val(ipmi_version, Properties)),
    ?assertEqual([event_generator, event_receiver, fru_inventory, sel, sdr],
                 eipmi_util:get_val(device_support, Properties)),
    ?assertEqual(27768, eipmi_util:get_val(manufacturer_id, Properties)),
    ?assertEqual(2819, eipmi_util:get_val(product_id, Properties)).

decode_cold_reset_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?COLD_RESET},
    Bin = <<>>,
    ?assertEqual([], eipmi_response:decode(Resp, Bin)).

decode_warm_reset_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?WARM_RESET},
    Bin = <<>>,
    ?assertEqual([], eipmi_response:decode(Resp, Bin)).

decode_get_device_guid_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?GET_DEVICE_GUID},
    Bin = <<$h, $e, $l, $l, $o>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual("hello", eipmi_util:get_val(guid, Properties)).

decode_get_system_guid_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?GET_SYSTEM_GUID},
    Bin = <<$h, $e, $l, $l, $o>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual("hello", eipmi_util:get_val(guid, Properties)).

decode_get_channel_authentication_capabilities_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?GET_CHANNEL_AUTHENTICATION_CAPABILITIES},
    Bin = <<16#00, 16#17, 16#1f, 16#00, 16#00, 16#00, 16#00, 16#00>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual([pwd, md5, md2, none],
                 eipmi_util:get_val(auth_types, Properties)),
    ?assertEqual([non_null, null, anonymous],
                 eipmi_util:get_val(login_status, Properties)).

decode_get_session_challenge_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?GET_SESSION_CHALLENGE},
    Bin = <<16#44, 16#33, 16#22, 16#11, $h, $e, $l, $l, $o, $_, $w, $o, $r,
            $l, $d, 16#00, 16#00, 16#00, 16#00, 16#00>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual(16#11223344, eipmi_util:get_val(session_id, Properties)),
    ?assertEqual(<<$h, $e, $l, $l, $o, $_, $w, $o, $r, $l, $d,
                   16#00, 16#00, 16#00, 16#00, 16#00>>,
                 eipmi_util:get_val(challenge, Properties)).

decode_activate_session_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?ACTIVATE_SESSION},
    Bin = <<16#00, 16#44, 16#33, 16#22, 16#11, 16#88, 16#77, 16#66, 16#55, 16#04>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual(none, eipmi_util:get_val(auth_type, Properties)),
    ?assertEqual(16#11223344, eipmi_util:get_val(session_id, Properties)),
    ?assertEqual(16#55667788, eipmi_util:get_val(inbound_seq_nr, Properties)),
    ?assertEqual(administrator, eipmi_util:get_val(privilege, Properties)).

decode_set_session_privilege_level_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?SET_SESSION_PRIVILEGE_LEVEL},
    Bin = <<16#04>>,
    Properties = eipmi_response:decode(Resp, Bin),
    ?assertEqual(administrator, eipmi_util:get_val(privilege, Properties)).

decode_close_session_test() ->
    Resp = {?IPMI_NETFN_APPLICATION_RESPONSE, ?CLOSE_SESSION},
    Bin = <<>>,
    ?assertEqual([], eipmi_response:decode(Resp, Bin)).
