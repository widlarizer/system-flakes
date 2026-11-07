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
  notFromAutomation = {
    condition = "template";
    value_template = "{{ trigger.to_state.context.parent_id is none }}";
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
      conditions = [ notFromAutomation ];
      actions = [
        {
          action = "switch.turn_{{ trigger.to_state.state }}";
          target.entity_id = obyvak.lights;
        }
      ];
    }
  ];
}
