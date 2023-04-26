import cpp

from FunctionCall fc
where fc.getTarget().getName() = "read"
select fc
