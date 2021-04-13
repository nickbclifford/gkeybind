require "./utils"

@[Link("xkbcommon")]
lib LibXKBCommon
  struct RuleNames
    rules : LibC::Char*
    model : LibC::Char*
    layout : LibC::Char*
    variant : LibC::Char*
    options : LibC::Char*
  end

  enum KeyDirection
    Up   = 0
    Down = 1
  end

  enum ContextFlags
    NoFlags            = 0
    NoDefaultIncludes  = 1
    NoEnvironmentNames = 2
  end

  enum KeymapCompileFlags
    NoFlags = 0
  end

  enum KeysymFlags
    NoFlags         = 0
    CaseInsensitive = 1
  end

  type Context = Void*
  type Keymap = Void*
  type State = Void*

  alias KeymapIterT = (Keymap, UInt32, Void* -> Void)
  alias KeysymT = UInt32

  fun context_new = xkb_context_new(flags : ContextFlags) : Context
  fun context_free = xkb_context_unref(context : Context)
  fun keymap_new = xkb_keymap_new_from_names(context : Context, names : RuleNames*, flags : KeymapCompileFlags) : Keymap
  fun keymap_for_each = xkb_keymap_key_for_each(keymap : Keymap, iter : KeymapIterT, data : Void*)
  fun keymap_free = xkb_keymap_unref(keymap : Keymap)
  fun keysym_from_name = xkb_keysym_from_name(name : LibC::Char*, flags : KeysymFlags) : KeysymT
  fun state_new = xkb_state_new(keymap : Keymap) : State
  fun state_free = xkb_state_unref(state : State)
  fun state_key_get_sym = xkb_state_key_get_one_sym(state : State, key : UInt32) : KeysymT
  fun state_update_key = xkb_state_update_key(state : State, key : UInt32, direction : KeyDirection)
  fun utf32_to_keysym = xkb_utf32_to_keysym(ucs : UInt32) : KeysymT
end

class Gkeybind::KeyLookup
  MODIFIERS = [Key::Leftshift, Key::Rightalt] # Shift, AltGr

  @hash = {} of LibXKBCommon::KeysymT => Array(Key)

  def initialize(layout_name : String? = nil)
    ctx = LibXKBCommon.context_new(LibXKBCommon::ContextFlags::NoFlags)
    names = LibXKBCommon::RuleNames.new(layout: layout_name.try(&.to_unsafe) || Pointer(LibC::Char).null)
    keymap = LibXKBCommon.keymap_new(ctx, pointerof(names), LibXKBCommon::KeymapCompileFlags::NoFlags)
    state = LibXKBCommon.state_new(keymap)

    # NOTE: XKB keycode values are 8 more than their evdev values

    # Generate all possible modifier combinations
    (0..MODIFIERS.size).flat_map {|i| MODIFIERS.combinations(i)}.each do |mods|
      mods.each do |mod|
        LibXKBCommon.state_update_key(state, mod + 8, LibXKBCommon::KeyDirection::Down)
      end

      iter keymap do |code|
        sym = LibXKBCommon.state_key_get_sym(state, code)
        # Modifiers need to come first!
        @hash[sym] = [Key.new(code.to_i - 8)].concat(mods).reverse unless @hash[sym]?
      end

      mods.each do |mod|
        LibXKBCommon.state_update_key(state, mod + 8, LibXKBCommon::KeyDirection::Up)
      end
    end

    LibXKBCommon.state_free(state)
    LibXKBCommon.keymap_free(keymap)
    LibXKBCommon.context_free(ctx)
  end

  def from_char(char : Char)
    @hash[LibXKBCommon.utf32_to_keysym(char.ord)]
  end

  def from_name(name : String)
    sym = LibXKBCommon.keysym_from_name(name, LibXKBCommon::KeysymFlags::NoFlags)
    abort "Invalid key name #{name}!" if sym == 0
    @hash[sym]
  end

  private def iter(keymap, &cb : UInt32 ->)
    LibXKBCommon.keymap_for_each(keymap, ->(map, key, data) {
      Box(typeof(cb)).unbox(data).call(key)
    }, Box.box(cb))
  end
end
