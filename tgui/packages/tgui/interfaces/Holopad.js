import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
} from '../components';
import { Window } from '../layouts';

export const Holopad = (props, context) => {
  const { act, data } = useBackend(context);
  const { calling } = data;
  return (
    <Window width={440} height={245} resizable>
      {!!calling && (
        <Modal fontSize="36px" fontFamily="monospace">
          <Flex align="center">
            <Flex.Item mr={2} mt={2}>
              <Icon name="phone-alt" rotation={25} />
            </Flex.Item>
            <Flex.Item mr={2}>{'Dialing...'}</Flex.Item>
          </Flex>
          <Box mt={2} textAlign="center" fontSize="24px">
            <Button
              lineHeight="40px"
              icon="times"
              content="Hang Up"
              color="bad"
              onClick={() => act('hang_up')}
            />
          </Box>
        </Modal>
      )}
      <Window.Content scrollable>
        <HolopadContent />
      </Window.Content>
    </Window>
  );
};

const HolopadContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on_network,
    on_cooldown,
    allowed,
    disk,
    disk_record,
    replay_mode,
    loop_mode,
    record_mode,
    holo_calls = [],
    em_hologram,
    em_active,
    em_cooldown,
  } = data;
  return (
    <>
      <Section
        title="Holopad"
        buttons={
          <Button
            icon="bell"
            content={
              on_cooldown ? "AI's Presence Requested" : "Request AI's Presence"
            }
            disabled={!on_network || on_cooldown}
            onClick={() => act('AIrequest')}
          />
        }
      >
        <LabeledList>
          {!!em_hologram && (
            <LabeledList.Item label="">
              <Button
                icon="bell"
                content={
                  em_active
                    ? 'Deactivate emergency ' + em_hologram + ' hologram'
                    : 'Activate emergency ' + em_hologram + ' hologram'
                }
                disabled={em_cooldown}
                color={em_active ? 'bad' : 'good'}
                onClick={() => act('em_action')}
              />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Communicator">
            <Button
              icon="phone-alt"
              content={allowed ? 'Connect To Holopad' : 'Call Holopad'}
              disabled={!on_network}
              onClick={() => act('holocall', { headcall: allowed })}
            />
          </LabeledList.Item>
          {holo_calls.map((call) => {
            return (
              <LabeledList.Item
                label={call.connected ? 'Current Call' : 'Incoming Call'}
                key={call.ref}
              >
                <Button
                  icon={call.connected ? 'phone-slash' : 'phone-alt'}
                  content={
                    call.connected
                      ? 'Disconnect call from ' + call.requester
                      : 'Answer call from ' + call.requester
                  }
                  color={call.connected ? 'bad' : 'good'}
                  disabled={!on_network}
                  onClick={() =>
                    act(call.connected ? 'disconnectcall' : 'connectcall', {
                      holopad: call.ref,
                    })
                  }
                />
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
      <Section
        title="Holodisk"
        buttons={
          <Button
            icon="eject"
            content="Eject"
            disabled={!disk || replay_mode || record_mode}
            onClick={() => act('disk_eject')}
          />
        }
      >
        {(!disk && <NoticeBox>No holodisk</NoticeBox>) || (
          <LabeledList>
            <LabeledList.Item label="Disk Player">
              <Button
                icon={replay_mode ? 'pause' : 'play'}
                content={replay_mode ? 'Stop' : 'Replay'}
                selected={replay_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('replay_mode')}
              />
              <Button
                icon={'sync'}
                content={loop_mode ? 'Looping' : 'Loop'}
                selected={loop_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('loop_mode')}
              />
              <Button
                icon="exchange-alt"
                content="Change Offset"
                disabled={!replay_mode}
                onClick={() => act('offset')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Recorder">
              <Button
                icon={record_mode ? 'pause' : 'video'}
                content={record_mode ? 'End Recording' : 'Record'}
                selected={record_mode}
                disabled={(disk_record && !record_mode) || replay_mode}
                onClick={() => act('record_mode')}
              />
              <Button
                icon="trash"
                content="Clear Recording"
                color="bad"
                disabled={!disk_record || replay_mode || record_mode}
                onClick={() => act('record_clear')}
              />
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </>
  );
};
