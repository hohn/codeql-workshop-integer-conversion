import cpp

class SignedInt extends IntType {
	SignedInt() {
		this.isSigned()
	}
}

class UnsignedInt extends IntType {
	UnsignedInt() {
		this.isUnsigned()
	}
}

class SignedToUnsignedConversion extends IntegralConversion {
  SignedToUnsignedConversion() {
    this.getExpr().getUnderlyingType() instanceof SignedInt and
    this.getUnderlyingType() instanceof UnsignedInt
  }
}
predicate isPossibleSizeParameter(Parameter p) {
  p.getName().toLowerCase().matches("%len%")
  or
  p.getName().toLowerCase().matches("%size%")
}

from FunctionCall call, int idx, Expr arg, Parameter p
where call.getArgument(idx) = arg and not arg.isConstant() and arg.getConversion() instanceof SignedToUnsignedConversion and
p = call.getTarget().getParameter(idx) and isPossibleSizeParameter(p)
select call, arg