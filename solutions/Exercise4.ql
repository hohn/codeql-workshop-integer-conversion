import cpp

class SignedInt extends IntType {
  SignedInt() { this.isSigned() }
}

class UnsignedInt extends IntType {
  UnsignedInt() { this.isUnsigned() }
}

class SignedToUnsignedConversion extends IntegralConversion {
  SignedToUnsignedConversion() {
    this.getExpr().getUnspecifiedType() instanceof SignedInt and
    this.getUnspecifiedType() instanceof UnsignedInt
  }
}

from FunctionCall call, VariableAccess arg
where call.getAnArgument() = arg and arg.getConversion() instanceof SignedToUnsignedConversion
select call, arg
