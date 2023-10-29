# frozen_string_literal: true

class Participant
  def initialize(name)
    @name = name
    @cards = []
    @score = 0
    @is_set = false
    @is_bust = false
    @is_surrender = false
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

  attr_reader :name, :cards, :score, :is_set, :is_bust, :is_surrender
end

class Player < Participant
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
  def hit?
    puts "#{@name}の現在の得点は#{@score}です。カードを引きますか？（Y/N）"

    response = gets.chomp
    if response == 'Y'
      true
    else
      @is_set = true
      false
    end
  end

  def select_double_down(trump_cards)
    puts "#{@name}の現在の得点は#{@score}です。ダブルダウンしますか？（Y/N）"

    response = gets.chomp
    if response == 'Y'
      self.draw_card(trump_cards)
      self.print_draw_card
      self.calculate_score
      @is_set = true
    end
  end

  def surrender?
    puts "#{@name}の現在の得点は#{@score}です。サレンダーしますか？（Y/N）"

    response = gets.chomp
    if response == 'Y'
      @is_surrender = true
    else
      false
    end
  end

  def split?
    puts "#{@name}の現在の得点は#{@score}です。スプリットしますか？（Y/N）"

    response = gets.chomp
    @is_split = true if response == 'Y'
  end
end

class PlayerAuto < Player
  include Automation
end

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
      if player.is_surrender
        puts "#{player.name}の負けです！"
        next
      end

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

class Card
  def initialize(card)
    @symbol = card[0]
    @num = card[1]
    calculate_num
  end

  private def calculate_num
    if ['J', 'Q', 'K'].include?(@num)
      @cal_num = 10
    elsif @num == 'A'
      @cal_num = 1
    else
      @cal_num = @num
    end
  end

  attr_reader :symbol, :num, :cal_num
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

(players + [dealer]).each do |participant|
  2.times do
    participant.draw_card(trump_cards)
    participant.print_draw_card
  end
  participant.calculate_score
end

if !player.surrender?
  player.select_double_down(trump_cards)

  if player.cards[0].cal_num == player.cards[1].cal_num && player.split?

    player_split = PlayerManual.new(:あなた_スプリット)
    players.insert(1, player_split)

    player_split.cards << player.cards.pop
    player.calculate_score
    player_split.calculate_score

    while !player_split.is_set && !player_split.is_bust
      if player_split.hit?
        player_split.draw_card(trump_cards)
        player_split.print_draw_card
        player_split.calculate_score
      end
    end
  end

  while !player.is_set && !player.is_bust && !player.is_surrender
    if player.hit?
      player.draw_card(trump_cards)
      player.print_draw_card
      player.calculate_score
    end
  end
end

cpu1.auto_draw(trump_cards)
cpu2.auto_draw(trump_cards)

puts "ディーラーの引いた2枚目のカードは#{dealer.cards[1].symbol}の#{dealer.cards[1].num}でした。"
dealer.auto_draw(trump_cards)
dealer.print_result(players)
puts 'ブラックジャックを終了します。'
