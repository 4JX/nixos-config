{ pkgs, p, ... }:

let
  inherit (p.mpv) shaders;
  inherit (pkgs) anime4k;

  setShader =
    { files, message }:
    ''no-osd change-list glsl-shaders set "${builtins.concatStringsSep ":" files}"; show-text "${message}"'';

  # editActiveRatio = package: filename: (pkgs.writeText filename (builtins.replaceStrings [ "1.300" ] [ "1.000" ] (builtins.readFile (package + "/" + filename))));
  # fsrcnnx_1x = with shaders; {
  #   x2_16 = editActiveRatio fsrcnnx "FSRCNNX_x2_16-0-4-1.glsl";
  # };
in
with shaders;
{
  # # https://github.com/NotAShelf/nyx/blob/b1f789e7b4da072cfbc912df90836c777c4555cf/pkgs/overlays/anime4k/default.nix
  # curl -sL https://raw.githubusercontent.com/bloc97/Anime4K/master/md/GLSL_Instructions_Linux.md | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e 's|;\$|:$|g' -e "s| |\" = ''|" -e 's|^|    "|' -e "s|$|'';|"
  # A for originally blurry lines, B for pretty sharp ones, C for potato resolution
  "CTRL+1" =
    ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
  "CTRL+2" =
    ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
  "CTRL+3" =
    ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
  "CTRL+4" =
    ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
  "CTRL+5" =
    ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
  "CTRL+6" =
    ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';

  "CTRL+7" = setShader {
    files = [
      SSimSuperRes
      SSimDownscaler
      KrigBilateral
    ];
    message = "SuperRes";
  };
  # "CTRL+8" = setShader {
  #   files = [ (fsrcnnx + /FSRCNNX_x2_8-0-4-1_LineArt.glsl) SSimDownscaler KrigBilateral ];
  #   message = "FSRCNNX 8 LineArt";
  # };
  # "CTRL+9" = setShader {
  #   files = [ (fsrcnnx + /FSRCNNX_x2_16-0-4-1.glsl) SSimDownscaler KrigBilateral ];
  #   message = "FSRCNNX 16";
  # };

  "CTRL+8" = setShader {
    files = [
      artcnn.C4F16
      SSimDownscaler
      KrigBilateral
    ];
    message = "ArtCNN C4F16";
  };

  "CTRL+9" = setShader {
    files = [
      artcnn.C4F32
      SSimDownscaler
      KrigBilateral
    ];
    message = "ArtCNN C4F32";
  };

  "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';

  "CTRL+h" = ''cycle-values tone-mapping "spline" "bt.2446a" "st2094-40" ; show-text "Tone-Map"'';
}
