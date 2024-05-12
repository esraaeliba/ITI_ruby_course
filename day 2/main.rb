require 'date'

module Logger 
  def log_info(message)
    log("info", message)
  end

  def log_warning(message)
    log("warning", message)
  end

  def log_error(message)
    log("error", message)
  end

  def log(log_type, message)
    timestamp = DateTime.now.strftime('%FT%T%:z')
    File.open("app.log", 'a') do |file|
      file.puts "#{timestamp} -- #{log_type} -- #{message}"
    end
  end
end

class User 
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end

end

class Transaction
  attr_reader :user, :value

  def initialize(user, value)
    @user = user
    @value = value
  end
end

class Bank
    def process_transactions(transactions, callback)
      raise NotImplementedError, "Abstract methos not implemented"
    end
end

class CBABank < Bank
  include Logger

  def initialize(users)
    @users = users
  end

  def process_transactions(transactions, callback)
    log_info("Processing Transactions #{transactions.map { |t| "#{t.user.name} transaction with value #{t.value}" }.join(', ')}")
    
    transactions.each do |transaction|
      begin
        if @users.include?(transaction.user)
          if transaction.user.balance + transaction.value < 0
            raise "Not enough balance"
          end
          
          transaction.user.balance += transaction.value
          
          callback.call("success", transaction)
          log_info("User #{transaction.user.name} transaction with value #{transaction.value} succeeded")

          if transaction.user.balance == 0
            log_warning("#{transaction.user.name} has 0 balance")
          end
          
        else
          raise "#{transaction.user.name} not exist in the bank!!"
        end
      rescue => e
        log_error("User #{transaction.user.name} transaction with value #{transaction.value} failed with message #{e.message}")
        callback.call("failure", transaction, e.message)
      end
    end
  end
end


users = [
  User.new("Ali", 200),
  User.new("Peter", 500),
  User.new("Manda", 100)
]

out_side_bank_users = [
  User.new("Menna", 400),
]

transactions = [
  Transaction.new(users[0], -20),
  Transaction.new(users[0], -30),
  Transaction.new(users[0], -50),
  Transaction.new(users[0], -100),
  Transaction.new(users[0], -100),
  Transaction.new(out_side_bank_users[0], -100)
]


bank = CBABank.new(users)

callback = ->(status, transaction, message = nil) {
  if status == "success"
    puts "Call endpoint for success of User #{transaction.user.name} transaction with value #{transaction.value}"
  elsif status == "failure"
    puts "Call endpoint for failure of User #{transaction.user.name} transaction with value #{transaction.value} with reason #{message}"
  end
}

bank.process_transactions(transactions, callback)