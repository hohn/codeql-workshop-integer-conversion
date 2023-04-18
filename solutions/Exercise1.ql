import cpp

class SignedInt extends IntType {
  SignedInt() { this.isSigned() }
}

from Variable v
where v.getUnspecifiedType() instanceof SignedInt
select v
