// GENERATED — do not edit by hand. Source of truth: the design
// `THEMES()` registry in Apps/Ratel Learning App Development/Ratel App.dc.html
// (L2178-2242). Regenerate: ratel-tools/gen_world_registry.py.
//
// The 31 selectable theme worlds (2 free: light, savanna; 29 Pro).
import 'package:flutter/widgets.dart';

import 'world_theme.dart';

/// Ids of the FREE worlds (design `FREE=['light','savanna']`, L3248).
const Set<String> kFreeWorldIds = <String>{'light', 'savanna'};

/// All 31 theme worlds, keyed by id, in design order.
const Map<String, ThemeWorld> kThemeWorlds = <String, ThemeWorld>{
  'light': ThemeWorld(
    id: 'light', label: 'Daylight', vehicle: 'Scooter', backdrop: 'none',
    isFree: true, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFE5E0D3), bg: Color(0xFFF6F3EC), bg2: Color(0xFFEFEBE0), surface: Color(0xFFFFFFFF), surface2: Color(0xFFF1EEE5), text: Color(0xFF1B1D1F), muted: Color(0xFF76746C), accent: Color(0xFF16A085), accent2: Color(0xFF0F7D68), ink: Color(0xFFFFFFFF), border: Color(0xFFE4E0D5), good: Color(0xFF2BA66B), bad: Color(0xFFE5573F), gold: Color(0xFFE0972B), shadow: Color(0x1A281E0A),
    ),
  ),
  'galaxy': ThemeWorld(
    id: 'galaxy', label: 'Space', vehicle: 'Star pod', backdrop: 'stars',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF020308), bg: Color(0xFF070A18), bg2: Color(0xFF05060F), surface: Color(0xB8121830), surface2: Color(0x12FFFFFF), text: Color(0xFFEEF3FF), muted: Color(0xFF9AB0FF), accent: Color(0xFF8FF0D6), accent2: Color(0xFF13A384), ink: Color(0xFF06241D), border: Color(0x24FFFFFF), good: Color(0xFF8FF0D6), bad: Color(0xFFFF8A6E), gold: Color(0xFFFFE08A), shadow: Color(0x73000000),
    ),
  ),
  'savanna': ThemeWorld(
    id: 'savanna', label: 'Savanna', vehicle: 'Safari jeep', backdrop: 'dust',
    isFree: true, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFC7A063), bg: Color(0xFFF1DCAF), bg2: Color(0xFFE6C588), surface: Color(0xFFFCF3DE), surface2: Color(0xFFEBD8B0), text: Color(0xFF3A2A12), muted: Color(0xFF8C6C40), accent: Color(0xFFE08A2B), accent2: Color(0xFFB96E18), ink: Color(0xFFFFFFFF), border: Color(0xFFDABF8E), good: Color(0xFF7C9A38), bad: Color(0xFFC2492C), gold: Color(0xFFC9851F), shadow: Color(0x295A3C0A),
    ),
  ),
  'ocean': ThemeWorld(
    id: 'ocean', label: 'Ocean', vehicle: 'Submarine', backdrop: 'bubbles',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF03161F), bg: Color(0xFF073143), bg2: Color(0xFF042430), surface: Color(0xB20A364A), surface2: Color(0x14FFFFFF), text: Color(0xFFE6F8FF), muted: Color(0xFF84BCD6), accent: Color(0xFF2BD4C4), accent2: Color(0xFF178F9E), ink: Color(0xFF04222E), border: Color(0x21FFFFFF), good: Color(0xFF34E0B0), bad: Color(0xFFFF7A8A), gold: Color(0xFFFFD98A), shadow: Color(0x66000000),
    ),
  ),
  'forest': ThemeWorld(
    id: 'forest', label: 'Forest', vehicle: 'Leaf glider', backdrop: 'fireflies',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF08160E), bg: Color(0xFF0F2B1B), bg2: Color(0xFF0A1F13), surface: Color(0xB2123020), surface2: Color(0x12FFFFFF), text: Color(0xFFE9F6E1), muted: Color(0xFF90BF89), accent: Color(0xFF9BE564), accent2: Color(0xFF57A235), ink: Color(0xFF0A2012), border: Color(0x1FFFFFFF), good: Color(0xFF9BE564), bad: Color(0xFFFF9E7A), gold: Color(0xFFF2D06B), shadow: Color(0x66000000),
    ),
  ),
  'candy': ThemeWorld(
    id: 'candy', label: 'Candy', vehicle: 'Balloon', backdrop: 'sprinkles',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFF4BDD8), bg: Color(0xFFFDE7F1), bg2: Color(0xFFFBD6E8), surface: Color(0xFFFFFFFF), surface2: Color(0xFFFBDDEC), text: Color(0xFF5A2A47), muted: Color(0xFFB0739A), accent: Color(0xFFFF5FA2), accent2: Color(0xFFE03D84), ink: Color(0xFFFFFFFF), border: Color(0xFFF6CADF), good: Color(0xFF36C79A), bad: Color(0xFFFF5B7A), gold: Color(0xFFF2A93B), shadow: Color(0x24A02864),
    ),
  ),
  'neon': ThemeWorld(
    id: 'neon', label: 'Neon City', vehicle: 'Hover-bike', backdrop: 'grid',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF05010C), bg: Color(0xFF0C0420), bg2: Color(0xFF080216), surface: Color(0xA81E0C3C), surface2: Color(0x297850C8), text: Color(0xFFECE4FF), muted: Color(0xFF9A7FD6), accent: Color(0xFF16E0FF), accent2: Color(0xFF0090C4), ink: Color(0xFF04101A), border: Color(0x5C825ADC), good: Color(0xFF16E0FF), bad: Color(0xFFFF4D7D), gold: Color(0xFFFFE36B), shadow: Color(0x80000000),
    ),
  ),
  'storm': ThemeWorld(
    id: 'storm', label: 'Rainstorm', vehicle: 'Storm glider', backdrop: 'rain',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF0A1622), bg: Color(0xFF122637), bg2: Color(0xFF0C1A28), surface: Color(0xB81C2E40), surface2: Color(0x14FFFFFF), text: Color(0xFFE7F0F8), muted: Color(0xFF93AEC6), accent: Color(0xFF5FB0E8), accent2: Color(0xFF2E6F9E), ink: Color(0xFF06121C), border: Color(0x21FFFFFF), good: Color(0xFF5FE0B0), bad: Color(0xFFFF8A6E), gold: Color(0xFFF2D06B), shadow: Color(0x73000000),
    ),
  ),
  'snow': ThemeWorld(
    id: 'snow', label: 'Winter', vehicle: 'Snow sled', backdrop: 'snow',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFF9FB6C8), bg: Color(0xFFC7DAE8), bg2: Color(0xFFAEC8DA), surface: Color(0xFFFFFFFF), surface2: Color(0xFFE8F1F8), text: Color(0xFF1E2D3A), muted: Color(0xFF6E8597), accent: Color(0xFF4FA3D1), accent2: Color(0xFF2E7AA8), ink: Color(0xFFFFFFFF), border: Color(0xFFD2E0EA), good: Color(0xFF2BA66B), bad: Color(0xFFE5573F), gold: Color(0xFFE0972B), shadow: Color(0x293C5A78),
    ),
  ),
  'sakura': ThemeWorld(
    id: 'sakura', label: 'Cherry Blossom', vehicle: 'Petal kite', backdrop: 'petals',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFF3C9D6), bg: Color(0xFFFDEEF2), bg2: Color(0xFFFBDDE7), surface: Color(0xFFFFFFFF), surface2: Color(0xFFFBE4EC), text: Color(0xFF4A2E3A), muted: Color(0xFFA6788A), accent: Color(0xFFEF8FB0), accent2: Color(0xFFD26A8E), ink: Color(0xFFFFFFFF), border: Color(0xFFF4D3DE), good: Color(0xFF5BB98C), bad: Color(0xFFE5677F), gold: Color(0xFFE0A84B), shadow: Color(0x21964664),
    ),
  ),
  'autumn': ThemeWorld(
    id: 'autumn', label: 'Autumn', vehicle: 'Leaf-cart', backdrop: 'leaves',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFB5611F), bg: Color(0xFFF3DCB8), bg2: Color(0xFFE9C58E), surface: Color(0xFFFFF6E6), surface2: Color(0xFFF0DBB8), text: Color(0xFF43240E), muted: Color(0xFF946A3E), accent: Color(0xFFD2691E), accent2: Color(0xFFA8480F), ink: Color(0xFFFFFFFF), border: Color(0xFFE2C79A), good: Color(0xFF7C9A38), bad: Color(0xFFC23B22), gold: Color(0xFFC9851F), shadow: Color(0x29783C0A),
    ),
  ),
  'aurora': ThemeWorld(
    id: 'aurora', label: 'Aurora', vehicle: 'Aurora skiff', backdrop: 'nlights',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF040A14), bg: Color(0xFF0A1428), bg2: Color(0xFF060E1E), surface: Color(0xB812203A), surface2: Color(0x12FFFFFF), text: Color(0xFFE6F0FF), muted: Color(0xFF8FB6D6), accent: Color(0xFF5FE0B0), accent2: Color(0xFF2E9E86), ink: Color(0xFF052018), border: Color(0x21FFFFFF), good: Color(0xFF5FE0B0), bad: Color(0xFFFF8A9E), gold: Color(0xFFFFE08A), shadow: Color(0x80000000),
    ),
  ),
  'volcano': ThemeWorld(
    id: 'volcano', label: 'Volcano', vehicle: 'Magma board', backdrop: 'embers',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF160B07), bg: Color(0xFF241310), bg2: Color(0xFF160B08), surface: Color(0xBD361A12), surface2: Color(0x0FFFFFFF), text: Color(0xFFFBE7DC), muted: Color(0xFFC99182), accent: Color(0xFFFF6A2B), accent2: Color(0xFFC7401A), ink: Color(0xFF1E0E08), border: Color(0x42FF8C50), good: Color(0xFFE0B23A), bad: Color(0xFFFF5A4D), gold: Color(0xFFFFB23A), shadow: Color(0x80000000),
    ),
  ),
  'sunset': ThemeWorld(
    id: 'sunset', label: 'Sunset', vehicle: 'Glider', backdrop: 'sunset',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF3A2740), bg: Color(0xFF5E3C56), bg2: Color(0xFF7A4A57), surface: Color(0xA8462A42), surface2: Color(0x1AFFFFFF), text: Color(0xFFFFF0E6), muted: Color(0xFFE0A99E), accent: Color(0xFFFF9E5A), accent2: Color(0xFFE0673C), ink: Color(0xFF3A1E1A), border: Color(0x42FFC8A0), good: Color(0xFF7FD0A0), bad: Color(0xFFFF6A6A), gold: Color(0xFFFFC95A), shadow: Color(0x6628141E),
    ),
  ),
  'desert': ThemeWorld(
    id: 'desert', label: 'Desert', vehicle: 'Dune buggy', backdrop: 'dunes',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFC98A3E), bg: Color(0xFFF0CE94), bg2: Color(0xFFE3B36A), surface: Color(0xFFFFF4DE), surface2: Color(0xFFEDD3A2), text: Color(0xFF4A2E12), muted: Color(0xFF977244), accent: Color(0xFFE0792B), accent2: Color(0xFFB85A16), ink: Color(0xFFFFFFFF), border: Color(0xFFDEC093), good: Color(0xFF8A9A38), bad: Color(0xFFC2492C), gold: Color(0xFFC9851F), shadow: Color(0x296E460F),
    ),
  ),
  'reef': ThemeWorld(
    id: 'reef', label: 'Coral Reef', vehicle: 'Glass boat', backdrop: 'reef',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF0A6E78), bg: Color(0xFF0E97A8), bg2: Color(0xFF0A7886), surface: Color(0xA8085662), surface2: Color(0x1FFFFFFF), text: Color(0xFFEAFEFF), muted: Color(0xFF9FE0E8), accent: Color(0xFFFF8A5B), accent2: Color(0xFFE0603A), ink: Color(0xFF053842), border: Color(0x29FFFFFF), good: Color(0xFF5FE0B0), bad: Color(0xFFFF6E7E), gold: Color(0xFFFFD36B), shadow: Color(0x4C00282E),
    ),
  ),
  'meadow': ThemeWorld(
    id: 'meadow', label: 'Meadow', vehicle: 'Bicycle', backdrop: 'meadow',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFF7FB45A), bg: Color(0xFFBFE3F2), bg2: Color(0xFFA6D8B0), surface: Color(0xFFFFFFFF), surface2: Color(0xFFE6F3E0), text: Color(0xFF26401C), muted: Color(0xFF6E8C5A), accent: Color(0xFF5BAE3A), accent2: Color(0xFF3F8A24), ink: Color(0xFFFFFFFF), border: Color(0xFFD2E6C8), good: Color(0xFF5BAE3A), bad: Color(0xFFE5673F), gold: Color(0xFFE0972B), shadow: Color(0x243C641E),
    ),
  ),
  'dawn': ThemeWorld(
    id: 'dawn', label: 'Dawn', vehicle: 'Sky balloon', backdrop: 'dawn',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFFE8A98E), bg: Color(0xFFFBE0CE), bg2: Color(0xFFF6C9C2), surface: Color(0xFFFFFFFF), surface2: Color(0xFFFBE2D6), text: Color(0xFF4A2E2E), muted: Color(0xFFA6788A), accent: Color(0xFFF2885A), accent2: Color(0xFFD6643C), ink: Color(0xFFFFFFFF), border: Color(0xFFF6D6C8), good: Color(0xFF5BB98C), bad: Color(0xFFE5677F), gold: Color(0xFFE0A84B), shadow: Color(0x21965A46),
    ),
  ),
  'beach': ThemeWorld(
    id: 'beach', label: 'Tropical Beach', vehicle: 'Catamaran', backdrop: 'beach',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFF1FA0B8), bg: Color(0xFF7FD6E8), bg2: Color(0xFFA9E4D0), surface: Color(0xFFFFFFFF), surface2: Color(0xFFDBF3F0), text: Color(0xFF0A3D44), muted: Color(0xFF5E8C92), accent: Color(0xFFFF9E3B), accent2: Color(0xFFE0742A), ink: Color(0xFF06343A), border: Color(0xFFC8EAE8), good: Color(0xFF2BB37A), bad: Color(0xFFFF6E6E), gold: Color(0xFFFFC44B), shadow: Color(0x29145A64),
    ),
  ),
  'mars': ThemeWorld(
    id: 'mars', label: 'Mars', vehicle: 'Rover', backdrop: 'mars',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF4A1E10), bg: Color(0xFF7A2E18), bg2: Color(0xFF5A2110), surface: Color(0xBD4A1E12), surface2: Color(0x12FFFFFF), text: Color(0xFFFBE2D2), muted: Color(0xFFD29B82), accent: Color(0xFFFF7A4B), accent2: Color(0xFFC2461E), ink: Color(0xFF2A1006), border: Color(0x42FF8C5A), good: Color(0xFFE0B23A), bad: Color(0xFFFF6A5A), gold: Color(0xFFFFB23A), shadow: Color(0x73000000),
    ),
  ),
  'jungle': ThemeWorld(
    id: 'jungle', label: 'Rainforest', vehicle: 'Zipline', backdrop: 'jungle',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF0A2615), bg: Color(0xFF123A22), bg2: Color(0xFF0C2A18), surface: Color(0xB8143422), surface2: Color(0x12FFFFFF), text: Color(0xFFE6F6E1), muted: Color(0xFF8FC79A), accent: Color(0xFF3FD08A), accent2: Color(0xFF23966A), ink: Color(0xFF08200F), border: Color(0x1FFFFFFF), good: Color(0xFF3FD08A), bad: Color(0xFFFF9E7A), gold: Color(0xFFFFD36B), shadow: Color(0x66000000),
    ),
  ),
  'cyberrain': ThemeWorld(
    id: 'cyberrain', label: 'Cyber Rain', vehicle: 'Hover-bike', backdrop: 'cyberrain',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF06040F), bg: Color(0xFF0B0A1E), bg2: Color(0xFF070614), surface: Color(0xB21A1234), surface2: Color(0x297850C8), text: Color(0xFFE6ECFF), muted: Color(0xFF8E8AC6), accent: Color(0xFFFF2D78), accent2: Color(0xFFC21A56), ink: Color(0xFF0A0A1A), border: Color(0x57785ADC), good: Color(0xFF16E0FF), bad: Color(0xFFFF4D7D), gold: Color(0xFFFFE36B), shadow: Color(0x80000000),
    ),
  ),
  'abyss': ThemeWorld(
    id: 'abyss', label: 'Deep Sea', vehicle: 'Bathysphere', backdrop: 'abyss',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF020A12), bg: Color(0xFF04121F), bg2: Color(0xFF020A12), surface: Color(0xB80A1E2E), surface2: Color(0x0FFFFFFF), text: Color(0xFFDCF2FF), muted: Color(0xFF7FA8C0), accent: Color(0xFF3FD0E0), accent2: Color(0xFF1E8FA0), ink: Color(0xFF02141E), border: Color(0x1AFFFFFF), good: Color(0xFF5FFFC2), bad: Color(0xFFFF7A8A), gold: Color(0xFFFFD98A), shadow: Color(0x80000000),
    ),
  ),
  'alpine': ThemeWorld(
    id: 'alpine', label: 'Alpine', vehicle: 'Cable car', backdrop: 'alpine',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFF6EA0C8), bg: Color(0xFFAED4EC), bg2: Color(0xFFCDE6F2), surface: Color(0xFFFFFFFF), surface2: Color(0xFFE6F1F8), text: Color(0xFF1E3A4A), muted: Color(0xFF5E8298), accent: Color(0xFF2E8FD0), accent2: Color(0xFF1E6FA8), ink: Color(0xFFFFFFFF), border: Color(0xFFD2E4EE), good: Color(0xFF2BB37A), bad: Color(0xFFE5573F), gold: Color(0xFFE0972B), shadow: Color(0x24325A78),
    ),
  ),
  'lavender': ThemeWorld(
    id: 'lavender', label: 'Lavender', vehicle: 'Vespa', backdrop: 'lavender',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFF7E5AA8), bg: Color(0xFFCDB6E6), bg2: Color(0xFFB89CD8), surface: Color(0xFFFFFFFF), surface2: Color(0xFFEDE2F6), text: Color(0xFF3A2750), muted: Color(0xFF7E6A94), accent: Color(0xFF9B5FD0), accent2: Color(0xFF7A3FB0), ink: Color(0xFFFFFFFF), border: Color(0xFFE0D2EE), good: Color(0xFF5BB98C), bad: Color(0xFFE5677F), gold: Color(0xFFE0A84B), shadow: Color(0x245A3282),
    ),
  ),
  'bamboo': ThemeWorld(
    id: 'bamboo', label: 'Bamboo Grove', vehicle: 'Rickshaw', backdrop: 'bamboo',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF0E3322), bg: Color(0xFF164A30), bg2: Color(0xFF0E3322), surface: Color(0xB816402A), surface2: Color(0x14FFFFFF), text: Color(0xFFE6F6E8), muted: Color(0xFF8FC79F), accent: Color(0xFF5FD08A), accent2: Color(0xFF2E9E66), ink: Color(0xFF08200F), border: Color(0x1FFFFFFF), good: Color(0xFF5FD08A), bad: Color(0xFFFF9E7A), gold: Color(0xFFFFD36B), shadow: Color(0x66000000),
    ),
  ),
  'lagoon': ThemeWorld(
    id: 'lagoon', label: 'Lagoon Night', vehicle: 'Kayak', backdrop: 'lagoon',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF06222E), bg: Color(0xFF0A3242), bg2: Color(0xFF06222E), surface: Color(0xB80C2E3C), surface2: Color(0x14FFFFFF), text: Color(0xFFDEF6FF), muted: Color(0xFF8FB8C8), accent: Color(0xFF2FD0C4), accent2: Color(0xFF1E9E94), ink: Color(0xFF04202A), border: Color(0x1CFFFFFF), good: Color(0xFF5FFFD0), bad: Color(0xFFFF8A9E), gold: Color(0xFFFFE08A), shadow: Color(0x73000000),
    ),
  ),
  'thunder': ThemeWorld(
    id: 'thunder', label: 'Thunderhead', vehicle: 'Storm chaser', backdrop: 'thunder',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF171A26), bg: Color(0xFF262B3C), bg2: Color(0xFF1A1E2C), surface: Color(0xBD282E40), surface2: Color(0x14FFFFFF), text: Color(0xFFE8ECF6), muted: Color(0xFF9AA2BC), accent: Color(0xFF8FA8E0), accent2: Color(0xFF5E72A8), ink: Color(0xFF0E1018), border: Color(0x1FFFFFFF), good: Color(0xFF6FE0C0), bad: Color(0xFFFF8A6E), gold: Color(0xFFFFD36B), shadow: Color(0x80000000),
    ),
  ),
  'nebula': ThemeWorld(
    id: 'nebula', label: 'Nebula', vehicle: 'Star cruiser', backdrop: 'nebula',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF0A0418), bg: Color(0xFF140A2A), bg2: Color(0xFF0A0418), surface: Color(0xB2241244), surface2: Color(0x12FFFFFF), text: Color(0xFFF0E6FF), muted: Color(0xFFB49ADE), accent: Color(0xFFC77FFF), accent2: Color(0xFF9B4FE0), ink: Color(0xFF1A0A2E), border: Color(0x21FFFFFF), good: Color(0xFF7FE0D6), bad: Color(0xFFFF8AC0), gold: Color(0xFFFFE08A), shadow: Color(0x80000000),
    ),
  ),
  'sandstorm': ThemeWorld(
    id: 'sandstorm', label: 'Sandstorm', vehicle: 'Caravan', backdrop: 'sandstorm',
    isFree: false, isDark: false,
    palette: WorldPalette(
      page: Color(0xFF7A4A1E), bg: Color(0xFFC78A44), bg2: Color(0xFFA86E2E), surface: Color(0xB2784A22), surface2: Color(0x1AFFFFFF), text: Color(0xFFFFF2DE), muted: Color(0xFFD9B488), accent: Color(0xFFE0852B), accent2: Color(0xFFB05E16), ink: Color(0xFF3A2410), border: Color(0x42FFDCAA), good: Color(0xFF9AA838), bad: Color(0xFFE5573F), gold: Color(0xFFFFC44B), shadow: Color(0x4C50320A),
    ),
  ),
  'cherrynight': ThemeWorld(
    id: 'cherrynight', label: 'Cherry Night', vehicle: 'Paper lantern', backdrop: 'cherrynight',
    isFree: false, isDark: true,
    palette: WorldPalette(
      page: Color(0xFF160A22), bg: Color(0xFF241040), bg2: Color(0xFF180A2C), surface: Color(0xB2301648), surface2: Color(0x14FFFFFF), text: Color(0xFFFCE6F2), muted: Color(0xFFC99AD0), accent: Color(0xFFFF8AC0), accent2: Color(0xFFD85FA0), ink: Color(0xFF1E0A2A), border: Color(0x1FFFFFFF), good: Color(0xFF7FE0C0), bad: Color(0xFFFF7A9E), gold: Color(0xFFFFD98A), shadow: Color(0x80000000),
    ),
  ),
};

/// Per-world traveller-vehicle GLYPH, keyed by the world id in [kThemeWorlds].
///
/// E2 (INC-10): every themed Home previously rendered the SAME hard-coded
/// honey-badger as the path "traveller", ignoring each world's authored
/// `vehicle:` string (shown only as a label in the themes picker). There is no
/// per-vehicle art in the design or `assets/` (the design ships the vehicle as
/// a label only), so — rather than hand-paint 31 sprites — each world's vehicle
/// is rendered as a single fitting emoji glyph in place of the badger. This map
/// is the ONE source of truth, derived directly from the real `vehicle:` names
/// in [kThemeWorlds] above (kept adjacent so the two never drift).
///
/// Where a vehicle has a clean standard emoji it is used verbatim (Scooter 🛵,
/// Balloon 🎈, Bicycle 🚲, Snow sled 🛷, Cable car 🚠, Kayak 🛶, Paper lantern
/// 🏮, Rickshaw 🛺, Kite 🪁). Where no exact emoji exists the closest sensible
/// glyph is chosen — these APPROXIMATIONS are flagged in the progress doc:
///  - Submarine / Bathysphere → 🤿 (diving; no submarine emoji exists)
///  - Leaf glider → 🍃, Leaf-cart → 🍂 (foliage; no cart/leaf-craft emoji)
///  - Hover-bike → 🏍️, Dune buggy / Safari jeep → 🚙 (nearest ground vehicle)
///  - Storm glider / Glider → 🪂 (paraglider); Magma board → 🏄 (board rider)
///  - Aurora skiff / Glass boat / Catamaran → ⛵ (sailboat)
///  - Rover → 🛻, Star cruiser → 🚀 (nearest craft)
///  - Zipline → 🧗 (aerial line / rope traveller); Storm chaser → 🌩️ (weather,
///    thematic not literal); Caravan → 🐪 (a desert camel caravan)
///
/// Galaxy (`Star pod`) is intentionally ABSENT: the Space Home keeps its bespoke
/// [PodTraveller] (a painted space pod), which already IS the world's Star-pod
/// vehicle — so it is left untouched rather than flattened to a glyph.
const Map<String, String> kWorldVehicleGlyphs = <String, String>{
  'light': '🛵', // Scooter
  'savanna': '🚙', // Safari jeep (approx: SUV)
  'ocean': '🤿', // Submarine (approx: diving)
  'forest': '🍃', // Leaf glider (approx: leaf)
  'candy': '🎈', // Balloon
  'neon': '🏍️', // Hover-bike (approx: motorcycle)
  'storm': '🪂', // Storm glider (approx: paraglider)
  'snow': '🛷', // Snow sled
  'sakura': '🪁', // Petal kite
  'autumn': '🍂', // Leaf-cart (approx: leaves)
  'aurora': '⛵', // Aurora skiff (approx: sailboat)
  'volcano': '🏄', // Magma board (approx: board rider)
  'sunset': '🪂', // Glider (approx: paraglider)
  'desert': '🚙', // Dune buggy (approx: SUV)
  'reef': '⛵', // Glass boat (approx: sailboat)
  'meadow': '🚲', // Bicycle
  'dawn': '🎈', // Sky balloon
  'beach': '⛵', // Catamaran (approx: sailboat)
  'mars': '🛻', // Rover (approx: pickup)
  'jungle': '🧗', // Zipline (approx: aerial line / rope)
  'cyberrain': '🏍️', // Hover-bike (approx: motorcycle)
  'abyss': '🤿', // Bathysphere (approx: diving)
  'alpine': '🚠', // Cable car
  'lavender': '🛵', // Vespa
  'bamboo': '🛺', // Rickshaw
  'lagoon': '🛶', // Kayak
  'thunder': '🌩️', // Storm chaser (approx: weather, thematic)
  'nebula': '🚀', // Star cruiser (approx: rocket)
  'sandstorm': '🐪', // Caravan (approx: camel caravan)
  'cherrynight': '🏮', // Paper lantern
};

/// The traveller glyph for the world [id], or `null` when the world has no glyph
/// mapping (only `galaxy`, which keeps its bespoke [PodTraveller]). A `null`
/// result tells the path to fall back to the historic honey-badger traveller.
String? worldVehicleGlyph(String id) => kWorldVehicleGlyphs[id];
