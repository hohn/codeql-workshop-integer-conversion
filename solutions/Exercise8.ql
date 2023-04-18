import cpp
import semmle.code.cpp.dataflow.DataFlow

class SignedInt extends IntType {
  SignedInt() { this.isSigned() }
}

class UnsignedInt extends IntType {
  UnsignedInt() { this.isUnsigned() }
}

class UnsignedToSigned extends IntegralConversion {
  UnsignedToSigned() {
    this.getExpr().getUnderlyingType() instanceof UnsignedInt and
    this.getUnderlyingType() instanceof SignedInt
  }
}

from FunctionCall call, int idx, Expr arg, Parameter p, PointerArithmeticOperation op
where
  call.getArgument(idx) = arg and
  arg.getConversion() instanceof UnsignedToSigned and
  p = call.getTarget().getParameter(idx) and
  DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(op.getAnOperand()))
select call, op, p
