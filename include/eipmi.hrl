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

-ifndef(eipmi_hrl_).
-define(eipmi_hrl_, 1).

%%%=============================================================================
%%% Protocol Defines
%%%=============================================================================

%%------------------------------------------------------------------------------
%% A zero value indicating reserved fields in protocol messages.
%%------------------------------------------------------------------------------
-define(EIPMI_RESERVED, 0).

%%------------------------------------------------------------------------------
%% The default RMCP port.
%%------------------------------------------------------------------------------
-define(RMCP_PORT_NUMBER, 623).

%%------------------------------------------------------------------------------
%% The channel number a session is requested for (default is the current channel).
%%------------------------------------------------------------------------------
-define(IPMI_REQUESTED_CHANNEL, 16#e).

%%------------------------------------------------------------------------------
%% The currently supported RMCP version (length is 8bits).
%%------------------------------------------------------------------------------
-define(RMCP_VERSION, 16#06).

%%------------------------------------------------------------------------------
%% The RMCP sequence number indicating that this message does not request a
%% reply/ack.
%%------------------------------------------------------------------------------
-define(RMCP_NOREPLY, 255).

%%------------------------------------------------------------------------------
%% The RMCP normal message type (length is 1bit).
%%------------------------------------------------------------------------------
-define(RMCP_NORMAL, 0).

%%------------------------------------------------------------------------------
%% The RMCP ACK message type (length is 1bit).
%%------------------------------------------------------------------------------
-define(RMCP_ACK, 1).

%%------------------------------------------------------------------------------
%% The RMCP ASF class identifier (length is 5bits).
%%------------------------------------------------------------------------------
-define(RMCP_ASF, 16#06).

%%------------------------------------------------------------------------------
%% The RMCP IPMI class identifier (length is 5bits).
%%------------------------------------------------------------------------------
-define(RMCP_IPMI, 16#07).

%%------------------------------------------------------------------------------
%% The ASF IANA prefix (length is 16bits, the enterprise numer is allowed to
%% take another 16bits).
%%------------------------------------------------------------------------------
-define(ASF_IANA, 4542).

%%------------------------------------------------------------------------------
%% The ASF message type for PONG messages (length is 8bits).
%%------------------------------------------------------------------------------
-define(ASF_PONG, 16#40).

%%------------------------------------------------------------------------------
%% The ASF message type for PING messages (length is 8bits).
%%------------------------------------------------------------------------------
-define(ASF_PING, 16#80).

%%------------------------------------------------------------------------------
%% The ASF message tag indicating that this message is not part of a
%% request/response pair.
%%------------------------------------------------------------------------------
-define(ASF_NOREPLY, 255).

%%------------------------------------------------------------------------------
%% The IPMI net function for sensor and event requests (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_SENSOR_EVENT_REQUEST, 16#04).

%%------------------------------------------------------------------------------
%% The IPMI net function for sensor and event responses (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_SENSOR_EVENT_RESPONSE, 16#05).

%%------------------------------------------------------------------------------
%% The IPMI net function for application requests (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_APPLICATION_REQUEST, 16#06).

%%------------------------------------------------------------------------------
%% The IPMI net function for application responses (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_APPLICATION_RESPONSE, 16#07).

%%------------------------------------------------------------------------------
%% The IPMI net function for storage requests (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_STORAGE_REQUEST, 16#0a).

%%------------------------------------------------------------------------------
%% The IPMI net function for storage responses (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_STORAGE_RESPONSE, 16#0b).

%%------------------------------------------------------------------------------
%% The IPMI net function for transport requests (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_TRANSPORT_REQUEST, 16#0c).

%%------------------------------------------------------------------------------
%% The IPMI net function for transport responses (length is 6bits).
%%------------------------------------------------------------------------------
-define(IPMI_NETFN_TRANSPORT_RESPONSE, 16#0d).

%%------------------------------------------------------------------------------
%% The default reponder address sent in all IPMI requests, currently this is
%% directly the BMC.
%%------------------------------------------------------------------------------
-define(IPMI_RESPONDER_ADDR, 16#20).

%%------------------------------------------------------------------------------
%% The default reponder logical unit (the BMC's event receiver function).
%%------------------------------------------------------------------------------
-define(IPMI_RESPONDER_LUN, 2#00).

%%------------------------------------------------------------------------------
%% The default requestor logical unit.
%%------------------------------------------------------------------------------
-define(IPMI_REQUESTOR_LUN, 2#00).

%%------------------------------------------------------------------------------
%% The supported FRU Information Storage Definition (v1.0)
%%------------------------------------------------------------------------------
-define(FRU_VERSION, 16#1).

%%%=============================================================================
%%% IPMI Commands
%%%=============================================================================

%% Global (Application)
-define(GET_DEVICE_ID, 16#01).                                      %% mandatory
-define(COLD_RESET, 16#02).                                         %%  optional
-define(WARM_RESET, 16#03).                                         %%  optional
-define(GET_SELF_TEST_RESULTS, 16#04).                              %% mandatory
-define(SET_ACPI_POWER_STATE, 16#06).                               %%  optional
-define(GET_ACPI_POWER_STATE, 16#07).                               %%  optional
-define(GET_DEVICE_GUID, 16#08).                                    %%  optional

%% BMC Watchdog (Application)
-define(RESET_WATCHDOG_TIMER, 16#22).                               %% mandatory
-define(SET_WATCHDOG_TIMER, 16#24).                                 %% mandatory
-define(GET_WATCHDOG_TIMER, 16#25).                                 %% mandatory

%% BMC Messaging (Application)
-define(SET_BMC_GLOBAL_ENABLES, 16#2e).                             %% mandatory
-define(GET_BMC_GLOBAL_ENABLES, 16#2f).                             %% mandatory
-define(CLEAR_MESSAGE_FLAGS, 16#30).                                %% mandatory
-define(GET_MESSAGE_FLAGS, 16#31).                                  %% mandatory
-define(GET_MESSAGE, 16#33).                                        %% mandatory
-define(SEND_MESSAGE, 16#34).                                       %% mandatory
-define(GET_SYSTEM_GUID, 16#37).                                    %%  optional
-define(GET_CHANNEL_AUTHENTICATION_CAPABILITIES, 16#38).            %% mandatory
-define(GET_SESSION_CHALLENGE, 16#39).                              %% mandatory
-define(ACTIVATE_SESSION, 16#3a).                                   %% mandatory
-define(SET_SESSION_PRIVILEGE_LEVEL, 16#3b).                        %% mandatory
-define(CLOSE_SESSION, 16#3c).                                      %% mandatory
-define(GET_SESSION_INFO, 16#3d).                                   %% mandatory
-define(GET_AUTHCODE, 16#3f).                                       %%  optional
-define(SET_CHANNEL_ACCESS, 16#40).                                 %% mandatory
-define(GET_CHANNEL_ACCESS, 16#41).                                 %% mandatory
-define(GET_CHANNEL_INFO, 16#42).                                   %% mandatory
-define(SET_USER_ACCESS, 16#43).                                    %% mandatory
-define(GET_USER_ACCESS, 16#44).                                    %% mandatory
-define(SET_USER_NAME, 16#45).                                      %%  optional
-define(GET_USER_NAME, 16#46).                                      %% mandatory
-define(SET_USER_PASSWORD, 16#47).                                  %% mandatory
-define(MASTER_WRITE_READ, 16#52).                                  %% mandatory

%% Events (Sensor/Event)
-define(SET_EVENT_RECEIVER, 16#00).
-define(GET_EVENT_RECEIVER, 16#01).
-define(PLATFORM_EVENT, 16#02).

%% PEF/Alerting (Sensor/Event)
-define(GET_PEF_CAPABILITIES, 16#10).
-define(ARM_PEF_POSTPONE_TIMER, 16#11).
-define(SET_PEF_CONFIGURATION_PARAMETERS, 16#12).
-define(GET_PEF_CONFIGURATION_PARAMETERS, 16#13).
-define(SET_LAST_PROCESSED_EVENT_ID, 16#14).
-define(GET_LAST_PROCESSED_EVENT_ID, 16#15).
-define(ALERT_IMMEDIATE, 16#16).
-define(PET_ACKNOWLEDGE, 16#17).

%% Sensor (Sensor/Event)
-define(GET_DEVICE_SDR_INFO, 16#20).
-define(GET_DEVICE_SDR, 16#21).
-define(RESERVE_DEVICE_SDR_REPOSITORY, 16#22).
-define(GET_SENSOR_READING_FACTORS, 16#23).
-define(SET_SENSOR_HYSTERESIS, 16#24).
-define(GET_SENSOR_HYSTERESIS, 16#25).
-define(SET_SENSOR_THRESHOLD, 16#26).
-define(GET_SENSOR_THRESHOLD, 16#27).
-define(SET_SENSOR_EVENT_ENABLE, 16#28).
-define(GET_SENSOR_EVENT_ENABLE, 16#29).
-define(RE_ARM_SENSOR_EVENTS, 16#2a).
-define(GET_SENSOR_EVENT_STATUS, 16#2b).
-define(GET_SENSOR_READING, 16#2d).
-define(SET_SENSOR_TYPE, 16#2e).
-define(GET_SENSOR_TYPE, 16#2f).
-define(SET_SENSOR_READING_AND_EVENT_STATUS, 16#30).

%% FRU (Storage)
-define(GET_FRU_INVENTORY_AREA_INFO, 16#10).                        %% mandatory
-define(READ_FRU_DATA, 16#11).                                      %% mandatory
-define(WRITE_FRU_DATA, 16#12).                                     %% mandatory

%% SDR (Storage)
-define(GET_SDR_REPOSITORY_INFO, 16#20).
-define(GET_SDR_REPOSITORY_ALLOCATION_INFO, 16#21).
-define(RESERVE_SDR_REPOSITORY, 16#22).
-define(GET_SDR, 16#23).
-define(ADD_SDR, 16#24).
-define(PARTIAL_ADD_SDR, 16#25).
-define(DELETE_SDR, 16#26).
-define(CLEAR_SDR_REPOSITORY, 16#27).
-define(GET_SDR_REPOSITORY_TIME, 16#28).
-define(SET_SDR_REPOSITORY_TIME, 16#29).
-define(ENTER_SDR_REPOSITORY_UPDATE_MODE, 16#2a).
-define(EXIT_SDR_REPOSITORY_UPDATE_MODE, 16#2b).
-define(RUN_INITIALIZATION_AGENT, 16#2c).

%% SEL (Storage)
-define(GET_SEL_INFO, 16#40).
-define(GET_SEL_ALLOCATION_INFO, 16#41).
-define(RESERVE_SEL, 16#42).
-define(GET_SEL_ENTRY, 16#43).
-define(ADD_SEL_ENTRY, 16#44).
-define(PARTIAL_ADD_SEL_ENTRY, 16#45).
-define(DELETE_SEL_ENTRY, 16#46).
-define(CLEAR_SEL, 16#47).
-define(GET_SEL_TIME, 16#48).
-define(SET_SEL_TIME, 16#49).
-define(GET_AUXILIARY_LOG_STATUS, 16#5a).
-define(SET_AUXILIARY_LOG_STATUS, 16#5b).

%% LAN (Transport)
-define(SET_LAN_CONFIGURATION_PARAMETERS, 16#01).
-define(GET_LAN_CONFIGURATION_PARAMETERS, 16#02).
-define(SUSPEND_BMC_ARPS, 16#03).
-define(GET_IP_UDP_RMCP_STATISTICS, 16#04).

%%%=============================================================================
%%% Messages
%%%=============================================================================

%%------------------------------------------------------------------------------
%% The RMCP message header.
%%------------------------------------------------------------------------------
-record(rmcp_header, {
          version = ?RMCP_VERSION :: 0..255,
          seq_nr  = ?RMCP_NOREPLY :: 0..255,
          class   = ?RMCP_ASF     :: 0..255}).

%%------------------------------------------------------------------------------
%% The RMCP ACK Message.
%%------------------------------------------------------------------------------
-record(rmcp_ack, {
          header :: #rmcp_header{}}).

%%------------------------------------------------------------------------------
%% The ASF Ping payload.
%%------------------------------------------------------------------------------
-record(asf_ping, {
          iana = ?ASF_IANA :: non_neg_integer(), %% the IANA enterprise number
          tag = 0          :: 0..255}).

%%------------------------------------------------------------------------------
%% The ASF Pong payload.
%%------------------------------------------------------------------------------
-record(asf_pong, {
          iana = ?ASF_IANA :: non_neg_integer(), %% the IANA enterprise number
          tag = 0          :: 0..255,
          oem = 0          :: non_neg_integer(), %% OEM defined values
          entities = []    :: [ipmi]}).          %% supported entities

%%------------------------------------------------------------------------------
%% An RMCP ASF Message.
%%------------------------------------------------------------------------------
-record(rmcp_asf, {
          header  :: #rmcp_header{},
          payload :: #asf_ping{} | #asf_pong{}}).

%%------------------------------------------------------------------------------
%% An RMCP IPMI Message.
%%------------------------------------------------------------------------------
-record(rmcp_ipmi, {
          header          :: #rmcp_header{},
          properties = [] :: proplists:proplist(),
          cmd             :: eipmi:request() | eipmi:response(),
          data = <<>>     :: binary()}).

-endif. %% eipmi_hrl_
