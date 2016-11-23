function UpdateSubscription(selectors) {
  this.priorNotificationRadioButtons = selectors.priorNotificationRadioButtons;
  this.enablePriorNotificationRadio = selectors.priorNotificationEnabled;
  this.priorNotificationDays = selectors.priorNotificationDays;
}

UpdateSubscription.prototype.init = function() {
  this.bindEvents();
  this.toggleNotificationDaysInput();
};

UpdateSubscription.prototype.bindEvents = function() {
  this.priorNotificationRadioButtons.on('change', this.handlePriorNotificationDaysInput());
};

UpdateSubscription.prototype.handlePriorNotificationDaysInput = function() {
  var _this = this;
  return function() {
    _this.toggleNotificationDaysInput();
  }
};

UpdateSubscription.prototype.toggleNotificationDaysInput = function() {
  if(!this.enablePriorNotificationRadio.is(':checked')) {
    this.priorNotificationDays.attr('disabled', 'disabled');
  } else {
    this.priorNotificationDays.removeAttr('disabled');
  }
};

$(function() {
  var selectors = {
    priorNotificationEnabled: $('#subscription_prior_notification_enabled_true'),
    priorNotificationDays: $('#subscription_prior_notification_days_gap'),
    priorNotificationRadioButtons: $('#subscription_prior_notification_enabled_field input[type="radio"]')
  };
  var updateSubscription = new UpdateSubscription(selectors);
  updateSubscription.init();
});
