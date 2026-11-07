{ pkgs, ... }:
let
  universe = 1;
  lampAddress = 1;
  minMireds = 154;
  maxMireds = 370;
in
{
  users.groups.ola = { };
  users.users.ola = {
    isSystemUser = true;
    group = "ola";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="05dc", ATTR{manufacturer}=="www.anyma.ch", ATTR{product}=="uDMX", GROUP="ola", MODE="0660"
  '';

  environment.systemPackages = [ pkgs.ola ];

  systemd.services.olad = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    preStart = ''
      grep -qs '^12-anyma-ilLUTZminator001-O-0 = ${toString universe}$' /var/lib/ola/ola-port.conf \
        || echo '12-anyma-ilLUTZminator001-O-0 = ${toString universe}' >> /var/lib/ola/ola-port.conf
    '';
    serviceConfig = {
      User = "ola";
      Group = "ola";
      StateDirectory = "ola";
      WorkingDirectory = "/var/lib/ola";
      ExecStart = "${pkgs.ola}/bin/olad -c /var/lib/ola --http-port 9090";
      Restart = "on-failure";
    };
  };

  services.home-assistant.config = {
    input_boolean.dmx_lamp_on.name = "DMX lamp on";
    input_number.dmx_lamp_brightness = {
      name = "DMX lamp brightness";
      min = 0;
      max = 255;
      step = 1;
    };
    input_number.dmx_lamp_mireds = {
      name = "DMX lamp color temperature";
      min = minMireds;
      max = maxMireds;
      step = 1;
    };

    rest_command.ola_set_dmx = {
      url = "http://127.0.0.1:9090/set_dmx";
      method = "post";
      content_type = "application/x-www-form-urlencoded";
      payload = "u={{ universe }}&d={{ values }}";
    };

    template = [
      {
        light = [
          {
            name = "DMX lamp";
            unique_id = "dmx_lamp";
            state = "{{ is_state('input_boolean.dmx_lamp_on', 'on') }}";
            level = "{{ states('input_number.dmx_lamp_brightness') | int }}";
            temperature = "{{ states('input_number.dmx_lamp_mireds') | int }}";
            min_mireds = minMireds;
            max_mireds = maxMireds;
            turn_on = [
              {
                action = "input_number.set_value";
                target.entity_id = "input_number.dmx_lamp_brightness";
                data.value = "{{ states('input_number.dmx_lamp_brightness') | int or 255 }}";
              }
              {
                action = "input_boolean.turn_on";
                target.entity_id = "input_boolean.dmx_lamp_on";
              }
            ];
            turn_off = [
              {
                action = "input_boolean.turn_off";
                target.entity_id = "input_boolean.dmx_lamp_on";
              }
            ];
            set_level = [
              {
                action = "input_number.set_value";
                target.entity_id = "input_number.dmx_lamp_brightness";
                data.value = "{{ brightness }}";
              }
              {
                action = "input_boolean.turn_on";
                target.entity_id = "input_boolean.dmx_lamp_on";
              }
            ];
            set_temperature = [
              {
                action = "input_number.set_value";
                target.entity_id = "input_number.dmx_lamp_mireds";
                data.value = "{{ color_temp }}";
              }
              {
                "if" = "{{ brightness is defined }}";
                "then" = [
                  {
                    action = "input_number.set_value";
                    target.entity_id = "input_number.dmx_lamp_brightness";
                    data.value = "{{ brightness }}";
                  }
                ];
              }
              {
                action = "input_boolean.turn_on";
                target.entity_id = "input_boolean.dmx_lamp_on";
              }
            ];
          }
        ];
      }
    ];

    "automation dmx" = [
      {
        id = "dmx_lamp_push";
        alias = "DMX lamp: send to OLA";
        mode = "restart";
        triggers = [
          {
            trigger = "state";
            entity_id = [
              "input_boolean.dmx_lamp_on"
              "input_number.dmx_lamp_brightness"
              "input_number.dmx_lamp_mireds"
            ];
          }
          {
            trigger = "homeassistant";
            event = "start";
          }
        ];
        actions = [
          {
            action = "rest_command.ola_set_dmx";
            data = {
              universe = universe;
              values = ''
                {%- set b = states('input_number.dmx_lamp_brightness') | int if is_state('input_boolean.dmx_lamp_on', 'on') else 0 -%}
                {%- set warm = (states('input_number.dmx_lamp_mireds') | int - ${toString minMireds}) / ${toString (maxMireds - minMireds)} -%}
                {%- set white = (b * [1, 2 * (1 - warm)] | min) | round | int -%}
                {%- set yellow = (b * [1, 2 * warm] | min) | round | int -%}
                {{ ([0] * ${toString (lampAddress - 1)} + [white, yellow]) | join(',') }}'';
            };
          }
        ];
      }
    ];
  };
}
