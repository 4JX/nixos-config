{ osConfig, lib, ... }:

let
  # Tie mangohud to the os-level gaming setting
  cfg = osConfig.local.programs.gaming;
in
{
  config = lib.mkIf cfg.enable {
    programs.mangohud = {
      enable = true;
      # https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf
      settings = {
        ### MangoHud configuration file
        ### Uncomment any options you wish to enable. Default options are left uncommented
        ### Use some_parameter=0 to disable a parameter (only works with on/off parameters)
        ### Everything below can be used / overridden with the environment variable MANGOHUD_CONFIG instead

        ################### VISUAL ###################

        ### Display MangoHud version
        version = true;

        ### Display the current GPU information
        ## Note: gpu_mem_clock also needs "vram" to be enabled
        gpu_stats = true;
        # gpu_temp
        gpu_core_clock = true;
        gpu_mem_clock = true;
        # gpu_power
        # gpu_text=GPU
        # gpu_load_change
        # gpu_load_value=60,90
        # gpu_load_color=39F900,FDFD09,B22222

        ### Display the current CPU information
        cpu_stats = true;
        # cpu_temp
        # cpu_power
        # cpu_text=CPU
        cpu_mhz = true;
        # cpu_load_change
        # cpu_load_value=60,90
        # cpu_load_color=39F900,FDFD09,B22222

        ### Display the current CPU load & frequency for each core
        # core_load
        # core_load_change

        ### Display IO read and write for the app (not system)
        # io_stats
        # io_read
        # io_write

        ### Display system vram / ram / swap space usage
        vram = true;
        ram = true;
        swap = true;

        ### Display FPS and frametime
        fps = true;
        # fps_sampling_period=500
        # fps_color_change
        # fps_value=30,60
        # fps_color=B22222,FDFD09,39F900
        frametime = true;
        # frame_count

        ### Display the frametime line graph
        frame_timing = true;
        # histogram

        ### Display GameMode / vkBasalt running status
        gamemode = true;
        # vkbasalt

        ### Change the hud position
        # position=top-left

        ### Change the corner roundness
        # round_corners=

        ### Disable / hide the hud by default
        # no_display

        ### Hud position offset
        # offset_x=
        # offset_y=

        ### Hud dimensions
        # width=
        # height=
        # table_columns=
        # cellpadding_y=

        ### Hud transparency / alpha
        # background_alpha=0.5
        # alpha=

        ################ INTERACTION #################

        ### Change toggle keybinds for the hud & logging
        # toggle_hud=Shift_R+F12
        # toggle_fps_limit=Shift_L+F1
        # toggle_logging=Shift_L+F2
        # reload_cfg=Shift_L+F4
        # upload_log=Shift_L+F3

        #################### LOG #####################
        ### Automatically start the log after X seconds
        # autostart_log=1
        ### Set amount of time in seconds that the logging will run for
        # log_duration=
        ### Change the default log interval, 100 is default
        # log_interval=100
        ### Set location of the output files (required for logging)
        # output_folder=/home/<USERNAME>/mangologs
        ### Permit uploading logs directly to FlightlessMango.com
        # permit_upload=1
        ### Define a '+'-separated list of percentiles shown in the benchmark results
        ### Use "AVG" to get a mean average. Default percentiles are 97+AVG+1+0.1
        # benchmark_percentiles=97,AVG,1,0.1 };
      };
    };
  };
}
