wax.bba = {}

function wax.bba.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO (sysver)
    local result = toobjc(UIDevice:currentDevice():systemVersion()):compare_options(sysver, 64)
    return result
end

function wax.bba.APPLICATION_FRAME_WIDTH()
    local size = CKCommonUtility:getApplicationSize()
    return size.width
end

function wax.bba.APPLICATION_FRAME_HEIGHT()
    local size = CKCommonUtility:getApplicationSize()
    return size.height
end

function wax.bba.XcodeAppVersion()
    local dict = NSBundle:mainBundle():infoDictionary()
    return dict["CFBundleShortVersionString"]
end