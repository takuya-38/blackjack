# frozen_string_literal: true

# Participantクラス
class Participant
  def initialize(name)
    @name = name
    @cards = []
    @score = 0
    @is_bust = false
  end

  def print_draw_card
    raise NotImplementedError, 'このメソッドはサブクラスでオーバーライドしてください。'
  end

  def draw_card(trump_cards)
    card = trump_cards.sample
    trump_cards.delete(card)
    @cards << Card.new(card)
  end

  def calculate_score
    score = 0
    ace_flag = false

    @cards.each do |card|
      if ['J', 'Q', 'K'].include?(card.num)
        score += 10
      elsif card.num == 'A'
        score += 1
        ace_flag = true
      else
        score += card.num
      end
    end

    score += 10 if ace_flag && score <= 11
    @score = score

    @is_bust = true if @score >= 22
  end

  attr_reader :name, :cards, :score, :is_bust
end

# playerクラス
class Player < Participant
  def print_draw_card
    puts "#{@name}の引いたカードは#{@cards[-1].symbol}の#{@cards[-1].num}です。"
  end

  def continue_draw?
    puts "#{@name}の現在の得点は#{@score}です。カードを引きますか？（Y/N）"
    response = gets.chomp

    if response == 'Y'
      true
    elsif response == 'N'
      false
    end
  end

  def print_result(dealer)
    puts "#{@name}の得点は#{@score}です。"
    puts "#{dealer.name}の得点は#{dealer.score}です。"

    if @is_bust && dealer.is_bust || @score == dealer.score
      puts '引き分けです！'
    elsif dealer.is_bust || @score > dealer.score && !@is_bust
      puts 'あなたの勝ちです！'
    else
      puts 'ティーラーの勝ちです！'
    end
  end
end

# dealerクラス
class Dealer < Participant
  def print_draw_card
    if @cards.length != 2
      puts "#{@name}の引いたカードは#{@cards[-1].symbol}の#{@cards[-1].num}です。"
    else
      puts "#{@name}の引いた2枚目のカードはわかりません。"
    end
  end
end

# cardクラス
class Card
  def initialize(card)
    @symbol = card[0]
    @num = card[1]
  end

  attr_reader :symbol, :num
end

# あなたとディーラーとトランプを作成
player = Player.new(:あなた)
dealer = Dealer.new(:ディーラー)
participants = [player, dealer]

symbol = ['ハート', 'ダイヤ', 'クローバー', 'スペード']
trump_cards = symbol.product([*2..10, 'A', 'J', 'Q', 'K'])

# ---ゲーム開始------------------------------------------------
puts 'ブラックジャックを開始します。'

# 【あなた】カードを2枚引く、引いたカードを2枚表示
# 【ディーラー】カードを2枚引く、引いたカードを1枚表示、1枚隠す
participants.each do |participant|
  2.times do
    participant.draw_card(trump_cards)
    participant.print_draw_card
    participant.calculate_score
  end
end

# 【あなた】カードを引くか選択
while !player.is_bust && player.continue_draw?
  player.draw_card(trump_cards)
  player.print_draw_card
  player.calculate_score
end

# ディーラーの2枚目のカード公開
puts "ディーラーの引いた2枚目のカードは#{dealer.cards[1].symbol}の#{dealer.cards[1].num}でした。"

# 【ディーラー】カードを17以上になるまで引く
while dealer.score < 17
  puts "#{dealer.name}の現在の得点は#{dealer.score}です。"
  dealer.draw_card(trump_cards)
  dealer.print_draw_card
  dealer.calculate_score
end

player.print_result(dealer)
puts 'ブラックジャックを終了します。'
