# Steam

Generate Noctalia CSS color variables for Steam's **Material-Theme** skin. This is not a standalone skin for unmodified Steam.

Install and configure Material-Theme and its required Steam skin-loading setup first, then enable **Steam** in **Noctalia Settings → Templates**. The template writes directly to:

```text
~/.steam/steam/steamui/skins/Material-Theme/css/main/colors/matugen.css
```

The stylesheet identifies the color scheme as `Matugen` and defines `--md-sys-color-*` variables from the Noctalia palette. Ensure your Material-Theme setup loads this color file; other Steam installation paths are not targeted by this manifest.

The generated file is overwritten on regeneration, so back up any existing custom file at that path. There is no post-hook to install the skin, select a color scheme, or reload Steam; apply changes through your skin loader's supported mechanism.
