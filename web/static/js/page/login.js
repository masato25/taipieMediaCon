import { Tabs, Button, Icon, Table, Layout, Row, Alert, Form, Breadcrumb, Col, TimePicker, Menu, DatePicker, Input, Modal, message} from 'antd'
const { Header, Content, Footer, Sider } = Layout
const FormItem = Form.Item;
import ReactDOM from 'react-dom'
import React from 'react'
import PropTypes from 'prop-types'
import moment from 'moment'
const TabPane = Tabs.TabPane
import ifetch from '../common/fetch.js'
import "./css/login.css"
const $ = require('jquery')
const _ = require('lodash')

class LoginPage extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      passtext: ""
    }
    this.changePass = this.changePass.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }
  changePass(e){
    this.setState({passtext: e.target.value})
  }
  onSubmit(){
    if(this.state.passtext == ""){
      //do noting
      return
    }
    ifetch("/api/login", "JSONPOST", {
      password: this.state.passtext
    }).then((e) => {
      if(e.status == "ok"){
        message.success("登入成功")
        this.setState({passtext: ""})
        document.cookie = "token_key=" + e.token
        window.location.replace("/")
      }else{
        message.error("登入失敗")
        this.setState({passtext: ""})
      }
    }).catch((e) => {
      message.error("登入失敗")
      this.setState({passtext: ""})
    })
  }
  render() {
    return (
      <Layout className={["layout", "main_layout"]} style={{ width: '100%', height: '100%' }}>
        <Content className={["main_layout"]} style={{ padding: '0 50px' }}>
          <div className="_raw_main">
            <Row style={{"margin-bottom": "20px"}}>
              <Col span={10}>
                <div className={"_d_head"}>
                  <span style={{"font-size": "18px", "font-weight": "bold"}}>
                    <Icon type="notification" />台北車站互動排程系統
                  </span>
                </div>
              </Col>
            </Row>
            <Row>
              <Col span={2}>
                <div style={{ margin: '4px' }}>
                  登入密碼:
                </div>
              </Col>
              <Col span={7}>
                <Input
                  prefix={<Icon type="lock" style={{ fontSize: 13 }} />}
                  type="password" placeholder="請輸入登入密碼"
                  value={this.state.passtext}
                  onChange={this.changePass}
                />
              </Col>
              <Col span={3} style={{ "margin-left": '4px'}}>
                <Button type="primary" onClick={this.onSubmit}>登入</Button>
              </Col>
            </Row>
          </div>
        </Content>
      </Layout>
    )
  }
}

var element = document.getElementById('app');
ReactDOM.render(<LoginPage />, element)
