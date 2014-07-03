waxClass{"CKSettingsViewController", protocols={"UITableViewDataSource", "UITableViewDelegate", "UMFeedbackDataDelegate"}}

function loadView(self)
    self.super:loadView()
    self:view():setBackgroundColor(UIColor:colorWithPatternImage(UIImage:imageNamed("main_view_bg.png")))
    self.settingsTable = UITableView:initWithFrame_style(CGRect(0.0, 0.0, 0.0, 0.0), UITableViewStyleGrouped)
    self.settingsTable:setFrame(CGRect(0.0, 0.0, 0.0, 0.0))
    local result = wax.bba.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("7.0")
    if result then
        self.settingsTable:setFrame(CGRect(0.0, STATUS_HEIGHT + NAVIGATIONBAR_HEIGHT, wax.bba.APPLICATION_FRAME_WIDTH(), wax.bba.APPLICATION_FRAME_HEIGHT() - TABBAR_HEIGHT - STATUS_HEIGHT - NAVIGATIONBAR_HEIGHT))
    else
        self.settingsTable:setFrame(CGRect(0.0, 0.0, wax.bba.APPLICATION_FRAME_WIDTH(), wax.bba.APPLICATION_FRAME_HEIGHT() - TABBAR_HEIGHT  - NAVIGATIONBAR_HEIGHT))
    end
    self.settingsTable:setDataSource(self)
    self.settingsTable:setDelegate(self)
    self.settingsTable:setAllowsMultipleSelection(false)
    self.settingsTable:setAllowsSelectionDuringEditing(false)
    self.settingsTable:setSeparatorStyle(UITableViewCellSeparatorStyleSingleLine)
    self.settingsTable:setBackgroundColor(UIColor:clearColor())
    self.settingsTable:setBackgroundView(UIView:init())
    self:View():addSubView(self.settingsTable)
end

function viewDidLoad(self)
    self.super:viewDidLoad()
    UMFeedback:sharedInstance():setAppkey_delegate("52d369b456240b8c500ef4c1", self)
end

function tableView_cellForRowAtIndexPath(self, tableView, indexPath)
    local cell = UITableViewCell:initWithStyle_reuseIdentifier(UITableViewCellStyleValue1, nil)
    cell:setBackgroundColor(UIColor:clearColor())
    cell:setAccessoryType(UITableViewCellAccessoryDisclosureIndicator)
    cell:setSelectionStyle(UITableViewCellSelectionStyleNone)
    if indexPath:row() == TSettingCommonRowFeedBack then
        cell:textLabel():setText("给点建议")
        cell:imageView():setImage(UIImage:imageNamed("settings_feedback.png"))
    elseif indexPath:row() == TSettingCommonRowRate then
        cell:textLabel():setText("给应用评分")
        cell:imageView():setImage(UIImage:imageNamed("settings_rate.png"))
    elseif indexPath:row() == TSettingCommonRowVersion then
        cell:textLabel():setText("版本")
        cell:imageView():setImage(UIImage:imageNamed("settings_rate.png"))
        cell:detailTextLabel():setText(wax.bba.XcodeAppVersion())
    end
    cell:textLabel():setFont(UIFont:systemFontOfSize(15.0))
    return cell
end

function tableView_didSelectRowAtIndexPath(self, tableView, indexPath)
    if indexPath:section() == TSettingSectionCommon and indexPath:row() == TSettingCommonRowFeedBack then
        MobClick:event("settingsFeedback")
        UMFeedback:showFeedback_withAppkey(CKRootViewController:sharedInstance(), "52d369b456240b8c500ef4c1")
    elseif indexPath:section() == TSettingSectionCommon and indexPath:row() == TSettingCommonRowRate then
        MobClick:event("settingsRate")
        CKCommonUtility:goRating()
    end
end

function tableView_numberOfRowsInSection(self, tableView, section)
    if section == TSettingSectionCommon then
        return TSettingCommonRowCount
    end
    return 0
end

function numberOfSectionsInTableView(self, tableView)
    return TSettingSectionCount
end




