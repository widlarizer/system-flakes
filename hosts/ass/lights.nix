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
in
{
  services.home-assistant.config."automation lights" = [
    {
      id = "obyvak_switches";
      alias = "Obývák: vypínače ovládají světla";
      mode = "queued";
      triggers = [
        {
          trigger = "state";
          entity_id = obyvak.switches;
          from = [ "on" "off" ];
          to = [ "on" "off" ];
        }
      ];
      actions = [
        {
          variables.targets = "{{ ${builtins.toJSON obyvak.lights} | reject('eq', trigger.entity_id) | reject('is_state', trigger.to_state.state) | list }}";
        }
        {
          condition = "template";
          value_template = "{{ targets | count > 0 }}";
        }
        {
          action = "switch.turn_{{ trigger.to_state.state }}";
          target.entity_id = "{{ targets }}";
        }
      ];
    }
  ];
}
