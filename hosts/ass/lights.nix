let
  obyvak = {
    switches = [ "switch.obyvak_minir4m_2" ];
    lights = [
      "switch.obyvak_minir4m_2"
      "switch.s60tpf_sonoff_1002a16cd4_1"
    ];
  };
  loznice = {
    switch = "switch.obyvak_minir4m_3";
    powerOn = "select.obyvak_minir4m_3_chovani_pri_zapnuti";
    lights = [
      "switch.s60tpf_sonoff_1002a16be4_1"
      "switch.s60tpf_sonoff_1002a15df7_1"
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
    {
      id = "loznice_switch";
      alias = "Ložnice: vypínač přepíná světla";
      mode = "queued";
      triggers = [
        {
          trigger = "state";
          entity_id = loznice.switch;
          from = "off";
          to = "on";
        }
      ];
      conditions = [ notFromAutomation ];
      actions = [
        {
          action = "switch.turn_{{ 'off' if ${builtins.toJSON loznice.lights} | select('is_state', 'on') | list else 'on' }}";
          target.entity_id = loznice.lights;
        }
      ];
    }
    {
      id = "loznice_relay_off";
      alias = "Ložnice: relé vypínače vždy vypnuté";
      mode = "queued";
      triggers = [
        {
          trigger = "state";
          entity_id = loznice.switch;
          to = "on";
        }
        {
          trigger = "homeassistant";
          event = "start";
        }
      ];
      actions = [
        {
          action = "switch.turn_off";
          target.entity_id = loznice.switch;
        }
        {
          action = "select.select_option";
          target.entity_id = loznice.powerOn;
          data.option = "off";
        }
      ];
    }
  ];
}
