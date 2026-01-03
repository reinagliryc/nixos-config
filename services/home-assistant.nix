{ config, pkgs, ... }:

{
services.home-assistant = {
  enable = true;

  extraComponents = [
    "met"
    "radio_browser"
    "backup"
    "esphome"
    "shelly"
    "bthome"
    "energy"
    "mill"
  ];
  config = {
    homeassistant = {
      unit_system = "metric";
      time_zone = "Europe/Paris";
      temperature_unit = "C";
      currency = "EUR";
      country = "FR";
    };
    default_config = {};
    http = {
      trusted_proxies = [ "127.0.0.1" ];
      use_x_forwarded_for = true;
    };
    system_log = {
      max_entries = 300;
    };
    # Modern template syntax - replaces legacy platform: template
    template = [
      {
        switch = [
          {
            name = "Ch Eulalie Heater Switch";
            unique_id = "ch_eulalie_heater_switch";
            state = "{{ is_state('switch.ch_eulalie_heater', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.ch_eulalie_heater";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.ch_eulalie_heater";
            };
          }
          {
            name = "Ch Leonard Heater Switch";
            unique_id = "ch_leonard_heater_switch";
            state = "{{ is_state('switch.ch_leonard_heater', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.ch_leonard_heater";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.ch_leonard_heater";
            };
          }
          {
            name = "Ch Parents Heater Switch";
            unique_id = "ch_parents_heater_switch";
            state = "{{ is_state('switch.ch_parents_heater', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.ch_parents_heater";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.ch_parents_heater";
            };
          }
          {
            name = "Salon Heater Switch";
            unique_id = "salon_heater_switch";
            state = "{{ is_state('switch.salon_heater', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.salon_heater";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.salon_heater";
            };
          }
          {
            name = "Sam Heater Switch";
            unique_id = "sam_heater_switch";
            state = "{{ is_state('switch.sam_heater', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.sam_heater";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.sam_heater";
            };
          }
          {
            name = "Bureau Heater Switch";
            unique_id = "bureau_heater_switch";
            state = "{{ is_state('switch.bureau_heater', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.bureau_heater";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.bureau_heater";
            };
          }
          {
            name = "Seche Serviette Switch";
            unique_id = "seche_serviette_switch";
            state = "{{ is_state('switch.seche_serviette', 'off') }}";
            turn_on = {
              service = "switch.turn_off";
              target.entity_id = "switch.seche_serviette";
            };
            turn_off = {
              service = "switch.turn_on";
              target.entity_id = "switch.seche_serviette";
            };
          }
        ];
      }
    ];
    climate = [
      {
        platform = "generic_thermostat";
        name = "ch-parents";
        unique_id = "ch-parents-thermostat";
        heater = "switch.ch_parents_heater_switch";
        target_sensor = "sensor.ch_parents_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 15;
        home_temp = 18.3;
        comfort_temp = 19;
        sleep_temp = 18.3;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }
      {
        platform = "generic_thermostat";
        name = "ch-eulalie";
        unique_id = "ch-eulalie-thermostat";
        heater = "switch.ch_eulalie_heater_switch";
        target_sensor = "sensor.ch_eulalie_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 15;
        home_temp = 19;
        comfort_temp = 20;
        sleep_temp = 18;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }
      {
        platform = "generic_thermostat";
        name = "ch-leonard";
        unique_id = "ch-leonard-thermostat";
        heater = "switch.ch_leonard_heater_switch";
        target_sensor = "sensor.ch_leonard_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 15;
        home_temp = 19.4;
        comfort_temp = 20;
        sleep_temp = 18;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }
      {
        platform = "generic_thermostat";
        name = "salon";
        unique_id = "salon-thermostat";
        heater = "switch.salon_heater_switch";
        target_sensor = "sensor.salon_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 15;
        home_temp = 19.5;
        comfort_temp = 20;
        sleep_temp = 18;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }
      {
        platform = "generic_thermostat";
        name = "sam";
        unique_id = "sam-thermostat";
        heater = "switch.sam_heater_switch";
        target_sensor = "sensor.sam_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 15;
        home_temp = 19.5;
        comfort_temp = 20;
        sleep_temp = 18;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }
      {
        platform = "generic_thermostat";
        name = "sdb";
        unique_id = "sdb-thermostat";
        heater = "switch.seche_serviette_switch";
        target_sensor = "sensor.sdb_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 15;
        home_temp = 19;
        activity_temp = 25;
        sleep_temp = 16;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }
      {
        platform = "generic_thermostat";
        name = "bureau";
        unique_id = "bureau-thermostat"; 
        heater = "switch.bureau_heater_switch";
        target_sensor = "sensor.bureau_temp";
        min_temp = 15;
        max_temp = 24;
        away_temp = 16;
        home_temp = 19;
        comfort_temp = 21;
        sleep_temp = 18;
        ac_mode = false;
        cold_tolerance = 0;
        hot_tolerance = 0.05;
        initial_hvac_mode = "heat";
        keep_alive = {
          seconds = 60;
        };
      }

    ];
    recorder = {
      include = {
        entities = [
          "sensor.index"
          "sensor.bureau_temp"
          "sensor.sam_temp"
          "sensor.salon_temp"
          "sensor.cuisine_temp"
          "sensor.frigo_temp"
          "sensor.ch_eulalie_temp"
          "sensor.ch_leonard_temp"
          "sensor.sdb_temp"
          "sensor.ch_parents_temp"
          "sensor.bureau_humidity"
          "sensor.sam_humidity"
          "sensor.salon_humidity"
          "sensor.cuisine_humidity"
          "sensor.frigo_humidity"
          "sensor.cuisine_humidity"
          "sensor.ch_eulalie_humidity"
          "sensor.ch_leonard_humidity"
          "sensor.ch_parents_humidity"
          "sensor.sdb_humidity"
          "sensor.index_cost"
          "climate.mill_cuisine"
          "climate.bureau"
          "climate.ch_eulalie"
          "climate.ch_leonard"
          "climate.ch_parents"
          "climate.salon"
          "climate.sam"
          "climate.sdb"
        ];
      };
    };
    timer.sdb = {
      duration = "00:30:00";
      icon = "mdi:heating-coil";
      restore = true;
    };
    automation = [
      {
        alias = "sdb-header";
        trigger = {
          platform = "state";
          entity_id = "timer.sdb";
          to = "active";
        };
        action = [
        	{
            service = "climate.set_preset_mode";
            data.preset_mode = "activity";
            target.entity_id = "climate.sdb";
          }
          {
            wait_for_trigger = {
              platform = "state";
              entity_id = "timer.sdb";
              to = "idle";
            };
          }
          {
            service = "climate.set_preset_mode";
            data.preset_mode = "away";
            target.entity_id = "climate.sdb";
          }
        ];
      }
    ];
  };
  package = (pkgs.home-assistant.override {
      extraPackages = py: with py; [ psycopg2 ];
    }).overrideAttrs (oldAttrs: {
      doInstallCheck = false;
    });
    config.recorder.db_url = "postgresql://@/hass";
  };  

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers =
      [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
  };

}
