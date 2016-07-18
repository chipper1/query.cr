module Query
  module CriteriaHelper
    def criteria(name)
      Criteria.new(name)
    end
  end

  module MacroHelper
    macro bi_operator(name, klass)
      def {{name.id}}(other) : Query
        {{klass.id}}.new(self, other)
      end
    end

    macro u_operator(name, klass)
      def {{name.id}} : Query
        {{klass.id}}.new(self)
      end
    end
  end

  module EqualityHelper
    def self.equals(left : Criteria, right : Criteria)
      left.name == right.name
    end

    def self.equals(left : Criteria, right)
      false
    end

    def self.equals(left, right)
      left == right
    end
  end

  class Query
    include MacroHelper

    bi_operator "&", And
    bi_operator "and", And
    bi_operator "|", Or
    bi_operator "or", Or
    bi_operator "xor", Xor
    bi_operator "^", Xor

    u_operator "not", Not

    def inspect(io)
      io << "Query"
    end
  end

  class EmptyQuery < Query
    def inspect(io)
      io << "EMPTY_QUERY"
    end

    macro empty_bi_operator(name)
      def {{name.id}}(other) : Query
        other
      end
    end

    empty_bi_operator "&"
    empty_bi_operator "and"
    empty_bi_operator "|"
    empty_bi_operator "or"

    def not : Query
      self
    end
  end

  class BiOperator(T) < Query
    getter left
    getter right

    def initialize(@left : Query, @right : T)
    end

    def ==(other : self)
      EqualityHelper.equals(left, other.left) &&
        EqualityHelper.equals(right, other.right)
    end

    def ==(other)
      false
    end

    def inspect(io)
      io << "#{self.class.name}<#{left.inspect}, #{right.inspect}>"
    end
  end

  class Equals(T) < BiOperator(T)
  end

  class NotEquals(T) < BiOperator(T)
  end

  class LessThan(T) < BiOperator(T)
  end

  class LessThanOrEqual(T) < BiOperator(T)
  end

  class MoreThan(T) < BiOperator(T)
  end

  class MoreThanOrEqual(T) < BiOperator(T)
  end

  class And(T) < BiOperator(T)
  end

  class Or(T) < BiOperator(T)
  end

  class Xor(T) < BiOperator(T)
  end

  class In(T) < BiOperator(T)
  end

  class UOperator < Query
    getter query

    def initialize(@query : Query)
    end

    def ==(other : self)
      EqualityHelper.equals(query, other.query)
    end

    def ==(other)
      false
    end

    def inspect(io)
      io << "#{self.class.name}<#{query.inspect}>"
    end
  end

  class Not < UOperator
  end

  class IsTrue < UOperator
  end

  class IsNotTrue < UOperator
  end

  class IsFalse < UOperator
  end

  class IsNotFalse < UOperator
  end

  class IsUnknown < UOperator
  end

  class IsNotUnknown < UOperator
  end

  class IsNull < UOperator
  end

  class IsNotNull < UOperator
  end

  class Criteria < Query
    getter name

    def initialize(@name : String)
    end

    def inspect(io)
      io << "'#{name}'"
    end

    include MacroHelper
    bi_operator "==", Equals
    bi_operator "!=", NotEquals
    bi_operator "<", LessThan
    bi_operator "<=", LessThanOrEqual
    bi_operator ">", MoreThan
    bi_operator ">=", MoreThanOrEqual
    bi_operator "in", In

    u_operator "is_true", IsTrue
    u_operator "is_not_true", IsNotTrue
    u_operator "is_false", IsFalse
    u_operator "is_not_false", IsNotFalse
    u_operator "is_unknown", IsUnknown
    u_operator "is_not_unknown", IsNotUnknown
    u_operator "is_null", IsNull
    u_operator "is_not_null", IsNotNull
  end
end
