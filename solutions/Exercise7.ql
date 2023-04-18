import cpp

class SignedInt extends IntType {
  SignedInt() { this.isSigned() }
}

class UnsignedInt extends IntType {
  UnsignedInt() { this.isUnsigned() }
}

class UnsignedToSigned extends IntegralConversion {
  UnsignedToSigned() {
    this.getExpr().getUnspecifiedType() instanceof UnsignedInt and
    this.getUnspecifiedType() instanceof SignedInt
  }
}

from UnsignedToSigned u
select u
