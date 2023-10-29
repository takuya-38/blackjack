# frozen_string_literal: true

# Participantクラス
class Participant
  def initialize(name)
    @name = name
    @cards = []
    @score = 0
    @is_bust = false
  end

  def draw_card(trump_cards)
    card = trump_cards.sample
    trump_cards.delete(card)
    @cards << Card.new(card)
  end

  def print_draw_card
    raise NotImplementedError, 'このメソッドはサブクラスでオーバーライドしてください。'
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
  def initialize(name)
    @name = name
    @cards = []
    @score = 0
    @is_bust = false
    # @result = ''
  end

  def print_draw_card
    puts "#{@name}の引いたカードは#{@cards[-1].symbol}の#{@cards[-1].num}です。"
  end

  def print_result(dealer)
    puts "#{@name}の得点は#{@score}です。"
    puts "#{dealer.name}の得点は#{dealer.score}です。"

    if @is_bust && dealer.is_bust || @score == dealer.score
      puts '引き分けです！'
    elsif dealer.is_bust || @score > dealer.score && !@is_bust
      puts "#{@name}の勝ちです！"
    else
      puts 'ティーラーの勝ちです！'
    end
  end
end

module Automation
  def auto_draw(trump_cards)
    while @score < 17
      puts "#{@name}の現在の得点は#{@score}です。"
      self.draw_card (trump_cards)
      self.print_draw_card
      self.calculate_score
    end
  end
end

class PlayerManual < Player
  def continue_draw?
    puts "#{@name}の現在の得点は#{@score}です。カードを引きますか？（Y/N）"
    response = gets.chomp

    if response == 'Y'
      true
    elsif response == 'N'
      false
    end
  end
end

class PlayerAuto < Player
  include Automation
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

  def print_result(players)
    (players + [self]).each do |participant|
      puts "#{participant.name}の得点は#{participant.score}です。"
    end

    players.each do |player|
      if player.is_bust && @is_bust || player.score == @score
        puts "#{player.name}は引き分けです！"
      elsif @is_bust || player.score > @score && !player.is_bust
        puts "#{player.name}の勝ちです！"
      else
        puts "#{player.name}の負けです！"
      end
    end
  end

  include Automation
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
player = PlayerManual.new(:あなた)
cpu1 = PlayerAuto.new(:CUP1)
cpu2 = PlayerAuto.new(:CPU2)
players = [player, cpu1, cpu2]

dealer = Dealer.new(:ディーラー)

symbol = ['ハート', 'ダイヤ', 'クローバー', 'スペード']
trump_cards = symbol.product([*2..10, 'A', 'J', 'Q', 'K'])

# ---ゲーム開始------------------------------------------------
puts 'ブラックジャックを開始します。'

# 【あなた】カードを2枚引く、引いたカードを2枚表示
# 【ディーラー】カードを2枚引く、引いたカードを1枚表示、1枚隠す
(players + [dealer]).each do |participant|
  2.times do
    participant.draw_card(trump_cards)
    participant.print_draw_card
  end
  participant.calculate_score
end

# 【あなた】カードを引くか選択
while !player.is_bust && player.continue_draw?
  player.draw_card(trump_cards)
  player.print_draw_card
  player.calculate_score
end

# CPUが引く
cpu1.auto_draw(trump_cards)
cpu2.auto_draw(trump_cards)

# ディーラーの2枚目のカード公開/【ディーラー】カードを17以上になるまで引く
puts "ディーラーの引いた2枚目のカードは#{dealer.cards[1].symbol}の#{dealer.cards[1].num}でした。"
dealer.auto_draw(trump_cards)

dealer.print_result(players)
puts 'ブラックジャックを終了します。'
