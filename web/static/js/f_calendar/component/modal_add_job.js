import { Button, Tooltip, Icon, Tabs, Layout, Row, Breadcrumb, Col, InputNumber, Select, TimePicker, Menu, DatePicker, Input, Modal, message} from 'antd'
const { Header, Content, Footer, Sider } = Layout
const TabPane = Tabs.TabPane
import ReactDOM from 'react-dom'
import React from 'react'
import PropTypes from 'prop-types'
import moment from 'moment'
import ifetch from '../../common/fetch.js'
import "../css/f_calendar.css"

const $ = require('jquery')
const _ = require('lodash')

class ModalAddJob extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      format: "HH:mm",
      updateObj: props.updateObj,
    }
  }
  shouldComponentUpdate(nextProps, nextState){
    return true
  }
  render() {
    return (
      <Modal
         title={<div style={{"font-size": "18px"}}><Icon type="question-circle" style={{color: '#ffce3d'}} /><span className={["_creat_modal_title"]}>請輸入操作</span></div>}
         visible={this.props.visible}
         onOk={this.props.handleOk} onCancel={this.props.handleCancel}
         cancelText={"取消"}
         okText={"送出"}
       >
        <Tabs defaultActiveKey="1" onChange={this.props.setAddAction}>
         <TabPane tab="建立節目" key="1">
           <Row className={"_creat_modal_row"}>
             <Col span={3}>
              <div style={{margin: '3px'}}>日期:</div>
             </Col>
             <Col span={10}>
               <DatePicker
                value={this.props.pickedD}
                format={"YYYY-MM-D"}
                onChange={this.props.setDate}/>
             </Col>
           </Row>
           <Row className={"_creat_modal_row"}>
             <Col span={3}>
              <div style={{margin: '3px'}}>期間:</div>
             </Col>
             <Col span={6}>
               <TimePicker
                placeholder={"please select a time"}
                onChange={this.props.setStime}
                value={this.props.pickedD}
                format={this.state.format} />
             </Col>
             <Col span={6}>
               <TimePicker
                placeholder={"please select a time"}
                onChange={this.props.setEtime}
                value={this.props.pickedDE}
                format={this.state.format} />
             </Col>
           </Row>
           <Row className={"_creat_modal_row"}>
             <Col span={3}>
              <div style={{margin: '3px'}}>選擇節目:</div>
             </Col>
             <Col span={15}>
               <Select style={{ width: 120 }} onChange={this.props.setPorgram}>
                 {
                   this.props.programs.map((object) => {
                     return (<Option key={object.id} value={object.id}>{object.name}</Option>)
                   })
                 }
               </Select>
             </Col>
           </Row>
         </TabPane>
         <TabPane tab="拷貝至下小時" key="2">
           <Row className={"_creat_modal_row"}>
             <Col span={3}>
              <div style={{margin: '3px'}}>日期:</div>
             </Col>
             <Col span={15}>
               <DatePicker
                 value={this.props.pickedD}
                 format={"YYYY-MM-D"}
                 onChange={this.props.setDate}
                 disabled
               />
             </Col>
           </Row>
           <Row className={"_creat_modal_row"}>
             <Col span={3}>
              <div style={{margin: '3px'}}>拷貝從:</div>
             </Col>
             <Col span={10}>
               <TimePicker
                  placeholder={"please select a time"}
                  value={this.props.pickedD}
                  onChange={this.props.setStime}
                  format={"HH"}
               />
             </Col>
           </Row>
           <Row className={"_creat_modal_row"}>
             <Col span={5}>
              <div style={{margin: '3px'}}>拷貝至之後的:</div>
             </Col>
             <Col span={5}>
              <Tooltip placement="topRight" title={"僅可輸入數值且為 1 ~ 23之間"}>
                <InputNumber min={1} max={23} value={this.props.copyToHour} onChange={this.props.setcopyToHour} />
              </Tooltip>
             </Col>
             <Col span={4}>
                <div>小時</div>
             </Col>
           </Row>
         </TabPane>
        </Tabs>
       </Modal>
    )
  }
}

module.exports = {ModalAddJob}
