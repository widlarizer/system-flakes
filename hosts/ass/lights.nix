let
  obyvak = {
    switches = [
      "switch.obyvak_minir4m_2"
      "switch.obyvak_minir4m_3"
    ];
    lights = [
      "switch.obyvak_minir4m_2"
      "switch.obyvak_minir4m_3"
      "switch.s60tpf_sonoff_1002a16cd4_1"
    ];
  };
  loznice = {
    switch = "switch.wifi_smart_switch";
    lights = [
      "switch.s60tpf_sonoff_1002a16be4_1"
      "switch.s60tpf_sonoff_1002a15df7_1"
    ];
  };
  online = lights: "${builtins.toJSON lights} | reject('is_state', 'unavailable')";
  physicalFlip = entity: {
    trigger = "state";
    entity_id = entity;
    from = [ "on" "off" ];
    to = [ "on" "off" ];
  };
in
{
  services.home-assistant.config."automation lights" = [
    {
      id = "obyvak_switches";
      alias = "Obývák: vypínače ovládají světla";
      mode = "queued";
      triggers = [ (physicalFlip obyvak.switches) ];
      actions = [
        {
          variables.targets = "{{ ${online obyvak.lights} | reject('eq', trigger.entity_id) | reject('is_state', trigger.to_state.state) | list }}";
        }
        {
          condition = "template";
          value_template = "{{ targets | count > 0 }}";
        }
        {
          action = "switch.turn_{{ trigger.to_state.state }}";
          target.entity_id = "{{ targets }}";
          continue_on_error = true;
        }
      ];
    }
    {
      id = "loznice_switch";
      alias = "Ložnice: vypínač přepíná světla";
      mode = "queued";
      triggers = [ (physicalFlip loznice.switch) ];
      actions = [
        {
          variables.targets = "{{ ${online loznice.lights} | list }}";
        }
        {
          condition = "template";
          value_template = "{{ targets | count > 0 }}";
        }
        {
          variables.new_state = "{{ 'off' if targets | select('is_state', 'on') | list | count > 0 else 'on' }}";
        }
        {
          action = "switch.turn_{{ new_state }}";
          target.entity_id = "{{ targets }}";
          continue_on_error = true;
        }
      ];
    }
  ];
}
