require 'minitest/autorun'

class TestString < Minitest::Test
  def setup
    @unsafe_pattern = /^[\.[:space:]]|[[:cntrl:][[:space:]&&[^\u0020\u3000]]"#\$%\&'\*,\/:;<=>\?\[\\\]\^`\{\|\}~]|[[:space:]]$|^$/
  end

  def test_forbidden_char
    assert(".dot" =~ @unsafe_pattern, "先頭の.はNG")
    assert_nil("abc.d1234" =~ @unsafe_pattern, "文中の.はOK")
    assert("$1234" =~ @unsafe_pattern, "$はどこでもNG")
    assert("100%ok" =~ @unsafe_pattern, "%はどこでもNG")
    assert("M&M" =~ @unsafe_pattern, "&はどこでもNG")
    assert("#hello" =~ @unsafe_pattern, "#はどこでもNG")
  end

  def test_zen_kana
    assert_nil(@unsafe_pattern =~ "フォルダ", "全角カナはOK")
    assert_nil(@unsafe_pattern =~ "フ゜ロシ゛ェクト", "全角カナはOK")
    assert_nil(@unsafe_pattern =~ "ふぉるだ", "全角ひらがなはOK")
    assert_nil(@unsafe_pattern =~ "ふぉるた゛", "全角ひらがなはOK")
  end

  def test_han_kana
    assert(@unsafe_pattern =~ "ﾌｫﾙﾀﾞ", "半角カナはNG")
  end

  def kanji
    # //   吉
    # // CJK UNIFIED IDEOGRAPH-5409
    # // Unicode: U+5409, UTF-8: E5 90 89
    assert_nil(@unsafe_pattern =~ "\u5409野屋", "漢字はOK")
    # // 𠮷
    # // CJK UNIFIED IDEOGRAPH-20BB7
    # // Unicode: U+20BB7, UTF-8: F0 A0 AE B7
    assert_nil(@unsafe_pattern =~ "\u{20BB7}野屋", "漢字サロゲートペアはOK")
  end

  def test_emoji
    assert_nil(@unsafe_pattern =~ "❤️", "絵文字はOK")
    assert_nil(@unsafe_pattern =~ "😄", "絵文字はOK")
    assert_nil(@unsafe_pattern =~ "💇🏻", "絵文字＋スキントーンはOK")
    assert(@unsafe_pattern =~ ".😓")
  end

  def test_greek
    assert_nil("α" =~ @unsafe_pattern, "ギリシャ語はOK")
    assert_nil("β" =~ @unsafe_pattern, "ギリシャ語はOK")
    assert_nil("η" =~ @unsafe_pattern, "ギリシャ語はOK")
    assert_nil("λ" =~ @unsafe_pattern, "ギリシャ語はOK")
  end

  def test_zen_space
    assert(@unsafe_pattern =~ "　こんにちは", "先頭の全角スペースはOK")
    assert_nil(@unsafe_pattern =~ "こんに　ちは", "文中の全角スペースはOK")
  end

  def test_han_space
    assert(@unsafe_pattern =~ " test", "先頭の半角スペースはNG")
    assert_nil(@unsafe_pattern =~ "test test", "文中の半角スペースはOK")
  end

  def test_meta_char
    assert("\t" =~ @unsafe_pattern, "制御文字はNG")
    assert("\r" =~ @unsafe_pattern, "制御文字はNG")
    assert("\n" =~ @unsafe_pattern, "制御文字はNG")
    assert("\b" =~ @unsafe_pattern, "制御文字はNG")
  end

end
