import cpp

class SignedInt extends IntType {
  SignedInt() { this.isSigned() }
}

from Variable v
where v.getUnderlyingType() instanceof SignedInt
select v
