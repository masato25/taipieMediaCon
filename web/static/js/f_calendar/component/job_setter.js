import React from 'react'
import moment from 'moment'
import { Modal, Button, TimePicker, Row, Col, Input, DatePicker } from 'antd'
const confirm = Modal.confirm

const format = 'HH:mm'

class JobSetter extends React.Component {
  constructor(props) {
    super(props)
    this.showConfirm = this.showConfirm.bind(this)
    this.onChange = this.onChange.bind(this)
  }
  onChange(e) {
    console.log(e)
  }
  showConfirm() {
    const self = this
    confirm({
      title: '請選擇時間',
      okText: 'ok',
      content: (
        <Row>
          <Col span={20}>
            <DatePicker onChange={this.onChange} />
          </Col>
          <Col span={10}>
            <TimePicker placeholder={"please select a time"} defaultValue={moment('00:00', format)} format={format} />
          </Col>
          <Col span={10}>
            <TimePicker placeholder={"please select a time"} defaultValue={moment('01:00', format)} format={format} />
          </Col>
          <Col span={20}>
            <Input placeholder="Basic usage" />
          </Col>
        </Row>
      ),
      cancelText: 'cancel',
      onOk() {
        debugger
        //this.props.addJob("okk")
      },
      onCancel() {
        console.log('Cancel')
      },
    });
  }
  render() {
    return (
      <div>
        <Button onClick={this.showConfirm}>
          建立工作
        </Button>
      </div>
    )
  }
}

module.exports = {JobSetter}
