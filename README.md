<div id ="management" class="big-div">
  <div ng-show="visiblePanel == PANELS.MANAGEMENT">
    
    <div class="item-bar">
      <div class="item-bar-text" id="item-bar">{{'PANEL.MANAGEMENT.UI008_014_1' | translate}}</div>
    </div>

    <label class="lbl-lv2" id="lbl-mag-1">{{'PANEL.MANAGEMENT.UI008_014_2' | translate}}</label>
    <!-- 2017-03-10 @thangvt #10711 -->
    <div class="inner-div2 common-section">
      <label class="lbl-import lbl-lv3" id="id-import">{{'PANEL.MANAGEMENT.UI008_014_68' | translate}}</label>
      <div id = "wapperupload-import">
        <div class="div-upload-import">
          <input type="file" file-model="myImportFile" id ="importFileUpload" accept=".tgz" style="display:none;">
          <label class="file-button-active" id="import-upload-file" for="importFileUpload" tabindex = "0">{{'PANEL.MANAGEMENT.UI008_014_57'| translate}}</label>
          <label class="selected-file-name" id="import-selected-file">&nbsp;</label>
          <label class="selected-file-size" id="import-selected-file-size">&nbsp;</label>
        </div>
        <cctvbutton class="cctv-btn" id="btn-upload-import" ng-click="uploadImportFile()"></cctvbutton>
      </div>
      <cctvbutton class="cctv-btn" id="btn-import" ng-click="importBtnHandler()"></cctvbutton>
    </div>
    <div class="inner-div2 common-section">
      <label style="display: inline;" class="lbl-lv3" id="lbl-mag-2">{{'PANEL.MANAGEMENT.UI008_014_10' | translate}}</label>
      <label id="lb-setting-target" style="display: inline;" class="lbl-lv3" id="lbl-mag-2">{{'PANEL.MANAGEMENT.UI008_014_60' | translate}}</label>
      <div class="div-in3">
        <div class="cctv-export-div">
          <cctvbutton class="cctv-btn" id="btn-export" ng-click="export()" href="#"></cctvbutton>
          <label id="lbl-mag-3">{{'PANEL.MANAGEMENT.UI008_014_14' | translate}}</label>
           <iframe src="app/components/ManagementSetting/download-iframe.html" id="download-iframe" style="width:0;height:0;border:0; border:none;" tabindex="-1"></iframe>
          <div class="cb-tg-1">
            <cctvcheckbox id="cb-tg-1" ng-model="targetSetting"></cctvcheckbox>
            <label>{{'PANEL.MANAGEMENT.UI008_014_61' | translate}}</label>
          </div>
          <div class="cb-tg-3">
            <cctvcheckbox id="cb-tg-3" ng-model="targetDB"></cctvcheckbox>
            <label>{{'PANEL.MANAGEMENT.UI008_014_63' | translate}}</label>
          </div>
          <div class="cb-tg-4">
            <cctvcheckbox id="cb-tg-4" ng-model="targetLog"></cctvcheckbox>
            <label>{{'PANEL.MANAGEMENT.UI008_014_64' | translate}}</label>
          </div>
        </div>
      </div>
    </div>
    <div class="inner-div2 common-section">
      <label class="lbl-lv3" id="lbl-mag-4">{{'PANEL.MANAGEMENT.UI008_014_19' | translate}}</label>
      <div class="div-in3">
        <cctvradiobutton id="rad-recorder" name="version-upgrade" ng-model="subPanelName" value="recorder" checked="true"></cctvradiobutton>
        
        <label id="lbl-mag-5">{{'PANEL.MANAGEMENT.UI008_014_20' | translate}}</label>
        <br/>
        
        <cctvradiobutton id="rad-camera" name="version-upgrade" ng-model="subPanelName" value="camera">
        </cctvradiobutton>
        
        <label id="lbl-mag-6">{{'PANEL.MANAGEMENT.UI008_014_21' | translate}}</label>
      <br/></div>
      <cctvbutton class="cctv-btn" id="btn-version-up" ng-click="upgradeVersion()"></cctvbutton>
    </div>
    <!-- 2017-11-20 @anhtb #12345 -->
    <div class="inner-div2 common-section">
      <label class="lbl-lv3" id="id-lbl-initialize">{{'PANEL.MANAGEMENT.UI008_014_15' | translate}}</label>
      <div class="div-in3">
        <cctvradiobutton id="rad-onlyrecord" name="initialize" value="onlyrecord" checked="true"></cctvradiobutton>
        
        <label id="lbl-mag-7">{{'PANEL.MANAGEMENT.UI008_014_16' | translate}}</label>
        <br/>
        
        <cctvradiobutton id="rad-all" name="initialize" value="all"></cctvradiobutton>
        
        <label id="lbl-mag-8">{{'PANEL.MANAGEMENT.UI008_014_17' | translate}}</label>
        <br/></div>
      <cctvbutton class="cctv-btn" id="btn-execute" ng-click="shutdownOrRestartClicked(0)"></cctvbutton>
    </div>
    <!-- 2017-07-03 @thangvt #10784 -->
    <div class="inner-div2 common-section">
      <label class="lbl-shutdown" id="id-lbl-shutdown">{{'PANEL.MANAGEMENT.UI008_014_65' | translate}}</label>
      <div class="div-shutdown">
          <cctvbutton class="cctv-btn" id="btn-restart" ng-click="shutdownOrRestartClicked(1)"></cctvbutton>
          <cctvbutton class="cctv-btn" id="btn-shutdown" ng-click="shutdownOrRestartClicked(0)"></cctvbutton>
      </div>
    </div>
  </div>
   <div id="recorder-upgrade"
    ng-show="visiblePanel == PANELS.RECORDER_UPGRADE"
    ng-include="recorderUpgradePath">
  </div>
  <div id="camera-upgrade"
    ng-show="visiblePanel == PANELS.CAMERA_UPGRADE"
    ng-include="cameraUpgradePath">
  </div>
   <div id="global-dialog"></div>
</div>
