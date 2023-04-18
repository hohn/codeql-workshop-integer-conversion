import cpp

class UnsignedInt extends IntType {
  UnsignedInt() { this.isUnsigned() }
}

from Variable v
where v.getUnderlyingType() instanceof UnsignedInt
select v
