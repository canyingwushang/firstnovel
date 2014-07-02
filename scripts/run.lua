wax.alert("title", "msg")

local result = wax.bba.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("5.0")
if result then
    print("a")
else
    print("b")
end