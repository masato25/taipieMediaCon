import React from 'react'
import moment from 'moment'
import { Modal, Button, TimePicker, Row, Col, Input, DatePicker, Tabs, Icon, message } from 'antd'
const TabPane = Tabs.TabPane
const confirm = Modal.confirm
import "../css/f_calendar.css"
const format = 'HH:mm'
import ifetch from '../../common/fetch.js'

class JobSetter extends React.Component {
  constructor(props) {
    super(props)
    this.moment = moment
    this.ifetch = ifetch
    this.messageComp = message
    this.state = {
      copyFrom: "",
      copyTo: "",
      deleteStart: "",
      deleteTimeStart: "00",
      deleteEnd: "",
      deleteTimeEnd: "00",
      deleteStart: "",
      deleteEnd: "",
      visible: false,
      tkey: "copy",
    }
    this.setcopyFrom = this.setcopyFrom.bind(this)
    this.setcopyTo = this.setcopyTo.bind(this)
    this.showModal = this.showModal.bind(this)
    this.hideModal = this.hideModal.bind(this)
    this.setdeleteStart = this.setdeleteStart.bind(this)
    this.setdeleteEnd = this.setdeleteEnd.bind(this)
    this.setdeleteTimeStart = this.setdeleteTimeStart.bind(this)
    this.setdeleteTimeEnd = this.setdeleteTimeEnd.bind(this)
    this.onOkSubmmit = this.onOkSubmmit.bind(this)
    this.onChangeTab = this.onChangeTab.bind(this)
    this.checkcopyParams = this.checkcopyParams.bind(this)
    this.checkDeleteParams = this.checkDeleteParams.bind(this)
  }
  setcopyFrom(e) {
    const self = this
    self.setState({
      copyFrom: e.format("YYYY-MM-D")
    })
  }
  setcopyTo(e) {
    const self = this
    self.setState({
      copyTo: e.format("YYYY-MM-D")
    })
  }
  setdeleteStart(e) {
    const self = this
    self.setState({
      deleteStart: e.format("YYYY-MM-D")
    })
  }
  setdeleteEnd(e) {
    const self = this
    self.setState({
      deleteEnd: e.format("YYYY-MM-D")
    })
  }
  setdeleteTimeStart(e) {
    const self = this
    self.setState({
      deleteTimeStart: e.format("HH")
    })
  }
  setdeleteTimeEnd(e) {
    const self = this
    self.setState({
      deleteTimeEnd: e.format("HH")
    })
  }
  showModal() {
    const self = this
    self.setState({
      visible: true
    })
  }
  hideModal() {
    const self = this
    self.setState({
      visible: false
    })
  }
  onOkSubmmit(){
    const self = this
    switch(self.state.tkey){
      case "copy":
        if(!self.checkcopyParams()){
          return
        }
        const copyFromStart = self.moment(self.state.copyFrom, "YYYY-MM-D").unix()
        //plus one day timestamp
        const copyFromEnd = self.moment(self.state.copyFrom, "YYYY-MM-D").unix() + 86400
        const copyTo = self.moment(self.state.copyTo, "YYYY-MM-D").unix()
        const timeDiff = copyTo - copyFromStart
        self.ifetch("/api/time_jobs_copy_day", "JSONPOST",{
          start_time: copyFromStart,
          end_time: copyFromEnd,
          copy_to: copyTo,
          job_template_id: self.props.job_template_id,
          time_diff: timeDiff,
        }).then((e) => {
          self.props.pushDataToEvents(e.data)
          self.setState({
            visible: false,
          })
          self.messageComp.success("拷貝成功")
        }).catch((e) => {
          console.log(e)
          self.messageComp.error("拷貝失敗請重新刷新頁面在重試")
        })
        break
      case "delete":
        const dstart = self.moment(`${this.state.deleteStart} ${this.state.deleteTimeStart}`, "YYYY-MM-D HH").unix()
        const dend = self.moment(`${this.state.deleteEnd} ${this.state.deleteTimeEnd}`, "YYYY-MM-D HH").unix()
        if(!self.checkDeleteParams(dstart, dend)){
          return
        }
        const template_id = self.props.job_template_id
        self.ifetch(`/api/time_jobs_delete_date?from_time=${dstart}&to_time=${dend}&job_template_id=${template_id}`, "DELETE").then((e) => {
          self.props.deleteEvents(e.data)
          self.setState({
            visible: false,
          })
          if(e.errors){
            self.messageComp.error(e.errors)
          } else {
            self.messageComp.success("刪除成功")
            setTimeout(
              function(){
                location.reload()
              }, 1000)
          }
        }).catch((e) => {
          self.messageComp.error("刪除失敗請重新刷新頁面在重試")
        })
        break
    }
  }
  checkcopyParams(){
    const self = this
    if(!self.state.copyFrom){
      self.messageComp.error("拷貝從不可為空")
      return false
    }
    if(!self.state.copyTo){
      self.messageComp.error("拷貝至不可為空")
      return false
    }
    return true
  }
  checkDeleteParams(dstart, dend){
    const self = this
    if(!self.state.deleteStart || !this.state.deleteTimeStart || !this.state.deleteEnd || !this.state.deleteTimeEnd){
      self.messageComp.error("輸入時間不完整,請檢查")
    }
    if(dstart > dend){
      self.messageComp.error("刪除至的時間不可以小於刪除從的時間")
      return false
    }
    return true
  }
  onChangeTab(e) {
    const self = this
    switch(e){
      case "1":
        self.setState({
          tkey: "copy"
        })
        break
      case "2":
        self.setState({
          tkey: "delete"
        })
        break
    }
  }
  render() {
    return (
      <div className={["copyAllDayItemDiv"]}>
        <Modal title={<div style={{"font-size": "18px"}}><Icon type="rocket" style={{color: '#4a139c'}} /><span className={["_creat_modal_title"]}>請選擇時間</span></div>}
            visible={this.state.visible}
            onOk={this.onOkSubmmit}
            onCancel={this.hideModal}
            okText="送出" cancelText="取消"
          >
          <Tabs defaultActiveKey="1" onChange={this.onChangeTab}>
            <TabPane tab={<div><Icon type="copy" style={{color: '#0c716b'}} />拷貝整天</div>} key="1">
              <Row className={"_creat_modal_row"}>
                <Col span={3}>
                  <div style={{margin: '3px'}}>拷貝從:</div>
                </Col>
                <Col span={15}>
                  <DatePicker onChange={this.setcopyFrom} />
                </Col>
              </Row>
              <Row className={"_creat_modal_row"}>
                <Col span={3}>
                  <div style={{margin: '3px'}}>拷貝至:</div>
                </Col>
                <Col span={15}>
                  <DatePicker onChange={this.setcopyTo} />
                </Col>
              </Row>
            </TabPane>
            <TabPane tab={<div><Icon type="file-excel" style={{color: '#c43516'}} />批次刪除區間</div>} key="2">
              <Row>
                <Col span={3}>
                  <div style={{margin: '3px'}}>刪除從:</div>
                </Col>
                <Col span={7}>
                  <DatePicker
                    onChange={this.setdeleteStart} />
                </Col>
                <Col span={5} style={{"margin-left": '5px'}}>
                  <TimePicker
                    onChange={this.setdeleteTimeStart}
                    placeholder={"please select a time"}
                    value={this.moment(this.state.deleteTimeStart, "HH")}
                    format={"HH"} />
                </Col>
                <Col span={3}>
                  <div style={{margin: '4px'}}>時</div>
                </Col>
              </Row>
              <Row>
                <Col span={3}>
                  <div style={{margin: '3px'}}>刪除至:</div>
                </Col>
                <Col span={7}>
                  <DatePicker
                    onChange={this.setdeleteEnd} />
                </Col>
                <Col span={5} style={{"margin-left": '5px'}}>
                  <TimePicker
                    onChange={this.setdeleteTimeEnd}
                    placeholder={"please select a time"}
                    value={this.moment(this.state.deleteTimeEnd, "HH")}
                    format={"HH"} />
                </Col>
                <Col span={3}>
                  <div style={{margin: '4px'}}>時</div>
                </Col>
              </Row>
            </TabPane>
          </Tabs>
        </Modal>
        <h1>{this.props.templateName}</h1>
        <Button onClick={this.showModal}>
          <Icon type="rocket" style={{color: '#4a139c'}} />
          <span style={{"font-weight": "bold"}}>整日拷貝/區間刪除</span>
        </Button>
      </div>
    )
  }
}

module.exports = {JobSetter}
