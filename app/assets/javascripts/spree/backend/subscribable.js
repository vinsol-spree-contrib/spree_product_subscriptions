function Subscribable($parentCheckbox, $childCheckboxesDiv) {
  this.$parentCheckbox = $parentCheckbox;
  this.$childCheckboxesDiv = $childCheckboxesDiv;
}

Subscribable.prototype.init = function() {
  this.bindEvents();
};

Subscribable.prototype.bindEvents = function() {
  this.bindParentCheckboxEvent();
};

Subscribable.prototype.bindParentCheckboxEvent = function() {
  var _this = this;
  this.$parentCheckbox.on("change", function() {
    if ($(this).prop("checked")) {
      _this.checkedParentCheckbox();
    } else {
      _this.uncheckedParentCheckbox();
    }
  });
};

Subscribable.prototype.checkedParentCheckbox = function() {
  this.$childCheckboxesDiv.removeClass("hidden");
  this.$childCheckboxesDiv.find("input").removeAttr("disabled");
};

Subscribable.prototype.uncheckedParentCheckbox = function() {
  this.$childCheckboxesDiv.addClass("hidden");
  this.$childCheckboxesDiv.find("input").attr("disabled", "disabled");
}

$(function() {
  var subscribable = new Subscribable($("#product_subscribable"), $("#subscribable_options"));
  subscribable.init();
});
