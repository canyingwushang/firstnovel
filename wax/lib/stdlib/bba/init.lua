wax.bba = {}

function wax.bba.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO (sysver)
    local result = UIDevice:currentDevice():systemVersion():compare_options(sysver, 64)
    if result then 
        return NSOrderedAscending
    else
        return NSOrderedDescending
    end
end