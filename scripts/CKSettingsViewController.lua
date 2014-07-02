waxClass{"CKSettingsViewController", protocols={"UITableViewDataSource", "UITableViewDelegate", "UMFeedbackDataDelegate"}}

function loadView(self)
    self.super:loadView()
    self:view():setBackgroundColor(UIColor:colorWithPatternImage(UIImage:imageNamed("main_view_bg.png")))
    self.settingsTable = UITableView:initWithFrame_style(CGRect(0.0, 0.0, 0.0, 0.0), UITableViewStyleGrouped)
end
    