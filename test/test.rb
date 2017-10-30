require 'minitest/autorun'


class TestString < Minitest::Test
  def setup
    @forbidden_start_pattern = /^[\.[:space:]]/
    @forbidden_anywhere_pattern = /[[:cntrl:][:space:]"#\$%\&'\*,\/:;<=>\?\[\\\]\^`\{\|\}~]/
    # file/folderはスペース類禁止
    @forbidden_anywhere_pattern_file = /[[:cntrl:][:space:]"#\$%\&'\*,\/:;<=>\?\[\\\]\^`\{\|\}~]/
    @forbidden_last_pattern = /[[:space:]]$/
    @forbidden_empty_pattern = /^$/
    @forbidden_windows_reserved_pattern = /^(?:CON|PRN|AUX|NUL|COM\d|LPT\d)(?:\.|$)/i
  end

  def test_forbidden_start_pattern
    assert(".dot" =~ @forbidden_start_pattern, "先頭の.はNG")
    assert("\x20dot" =~ @forbidden_start_pattern, "先頭の半角スペースはNG")
    assert("\u3000dot" =~ @forbidden_start_pattern, "先頭の全角スペースはNG") # JSだとプロジェクト名では許容
    assert("\tdot" =~ @forbidden_start_pattern, "先頭のwhitespaceはNG")
    assert("\rdot" =~ @forbidden_start_pattern, "先頭のwhitespaceはNG")
    assert("\ndot" =~ @forbidden_start_pattern, "先頭のwhitespaceはNG")
    assert("\vdot" =~ @forbidden_start_pattern, "先頭のwhitespaceはNG")
    assert("\fdot" =~ @forbidden_start_pattern, "先頭のwhitespaceはNG")
  end

  def test_forbidden_last_pattern
    assert("dot\x20" =~ @forbidden_last_pattern, "末尾の半角スペースはNG")
    assert("dot\u3000" =~ @forbidden_last_pattern, "末尾の全角スペースはNG") # JSだとプロジェクト名では許容
    assert("dot\t" =~ @forbidden_last_pattern, "末尾のwhitespaceはNG")
    assert("dot\r" =~ @forbidden_last_pattern, "末尾のwhitespaceはNG")
    assert("dot\n" =~ @forbidden_last_pattern, "末尾のwhitespaceはNG")
    assert("dot\v" =~ @forbidden_last_pattern, "末尾のwhitespaceはNG")
    assert("dot\f" =~ @forbidden_last_pattern, "末尾のwhitespaceはNG")
  end

  def test_zen_kana
    assert_nil(@forbidden_anywhere_pattern =~ "フォルダ", "全角カナはOK")
    assert_nil(@forbidden_anywhere_pattern =~ "フ゜ロシ゛ェクト", "全角カナはOK")
    assert_nil(@forbidden_anywhere_pattern =~ "ふぉるだ", "全角ひらがなはOK")
    assert_nil(@forbidden_anywhere_pattern =~ "ふぉるた゛", "全角ひらがなはOK")
  end

  def test_han_kana
    assert_nil(@forbidden_anywhere_pattern =~ "ﾌｫﾙﾀﾞ", "半角カナはOK")
  end

  def kanji
    # //   吉
    # // CJK UNIFIED IDEOGRAPH-5409
    # // Unicode: U+5409, UTF-8: E5 90 89
    assert_nil(@forbidden_anywhere_pattern =~ "\u5409野屋", "漢字はOK")
    # // 𠮷
    # // CJK UNIFIED IDEOGRAPH-20BB7
    # // Unicode: U+20BB7, UTF-8: F0 A0 AE B7
    assert_nil(@forbidden_anywhere_pattern =~ "\u{20BB7}野屋", "漢字サロゲートペアはOK")
  end

  def test_emoji
    assert_nil(@forbidden_anywhere_pattern =~ "❤️", "絵文字はOK")
    assert_nil(@forbidden_anywhere_pattern =~ "😄", "絵文字はOK")
    assert_nil(@forbidden_anywhere_pattern =~ "💇🏻", "絵文字＋スキントーンはOK")
  end

  def test_greek
    assert_nil("α" =~ @forbidden_anywhere_pattern, "ギリシャ語はOK")
    assert_nil("β" =~ @forbidden_anywhere_pattern, "ギリシャ語はOK")
    assert_nil("η" =~ @forbidden_anywhere_pattern, "ギリシャ語はOK")
    assert_nil("λ" =~ @forbidden_anywhere_pattern, "ギリシャ語はOK")
  end

  def test_zen_space?
    assert(@forbidden_anywhere_pattern =~ "　", "Project:文中の全角スペースはNG")
    assert(@forbidden_anywhere_pattern_file =~ "　", "File/Folder:文中の全角スペースはNG")
  end

  def test_han_space?
    assert(@forbidden_anywhere_pattern =~ " ", "Project:文中の半角スペースはNG")
    assert(@forbidden_anywhere_pattern_file =~ " ", "File/Folder:文中の半角スペースはNG")
  end

  def test_filesystem_char?
    assert(@forbidden_anywhere_pattern =~ "\"#\$%\&'\*,\/:;<=>\?\[\\\]\^`\{\|\}~", "ファイルシステムで使われる文字はNG")
  end

  def test_meta_char?
    # \x00-\x1F\x7F
    assert("\x00" =~ @forbidden_anywhere_pattern, "制御文字はNG")
    assert("\x1F" =~ @forbidden_anywhere_pattern, "制御文字はNG")
    assert("\x7F" =~ @forbidden_anywhere_pattern, "制御文字はNG")
  end

  def test_empty_char?
    assert("" =~ @forbidden_empty_pattern, "空文字はNG")
  end

  def test_endwith_windows_forbidden_pattern?
    assert("CON" =~ @forbidden_windows_reserved_pattern, "Windowsの予約名なのでNG")
    assert("PRN." =~ @forbidden_windows_reserved_pattern, "Windowsの予約名なのでNG")
    assert("AUX" =~ @forbidden_windows_reserved_pattern, "Windowsの予約名なのでNG")
    assert("NUL" =~ @forbidden_windows_reserved_pattern, "Windowsの予約名なのでNG")
    assert("COM0" =~ @forbidden_windows_reserved_pattern, "Windowsの予約名なのでNG")
    assert("LPT3." =~ @forbidden_windows_reserved_pattern, "Windowsの予約名なのでNG")
  end

end
