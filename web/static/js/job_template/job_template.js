import { Tabs, Button, Table, Layout, Row, Alert, Form, Breadcrumb, Col, TimePicker, Menu, DatePicker, Input, Modal, message} from 'antd'
const { Header, Content, Footer, Sider } = Layout
const FormItem = Form.Item;
import ReactDOM from 'react-dom'
import React from 'react'
import PropTypes from 'prop-types'
import moment from 'moment'
const TabPane = Tabs.TabPane
import {PageHeader} from "../common/page_header.js"
import "./css/job_template.css"
import ifetch from '../common/fetch.js'
const $ = require('jquery')
const _ = require('lodash')

class JobTemplatePage extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      columns: [{
        title: '樣板名稱',
        dataIndex: 'name',
        render: (e,record) => {
          return (
            <a href={`/template/${record.id}`}>{e}</a>
          )
        }
      }, {
        title: 'Action',
        dataIndex: '',
        key: 'x',
        render: (e) => {
          return (
            <div>
              <a href={"#"} onClick={(o) => {o.preventDefault(); this.getUpdate(e); this.showModal(o, "edit")} }>更新</a> |
              <a href={"#"}  onClick={(o) => {o.preventDefault(); this.getUpdate(e); this.showModal(o, "delete")} }>刪除</a>
            </div>
          )
        }
      }],
      data: [],
      visible: false,
      id: 0,
      name: '',
      action: 'new',
    }
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleOk = this.handleOk.bind(this)
    this.showModal = this.showModal.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    this.setInput = this.setInput.bind(this)
    this.cleanForm = this.cleanForm.bind(this)
    this.getUpdate = this.getUpdate.bind(this)
  }
  componentWillMount(){
    ifetch("/api/job_template", "GET").then((e) => {
      this.setState({
        data: e.data,
      })
    })
  }
  getUpdate(e) {
    this.setState({
      id: e.id,
      name: e.name,
    })
  }
  handleOk(e) {
    if(this.state.name == ""){
      message.error("樣板名稱不可為空白")
    }
    let thisfecth = ""
    switch (this.state.action) {
      case "new":
        thisfecth = ifetch("/api/job_template", "JSONPOST",
          {
            job_template:{
              name: this.state.name,
            }
          }).then((body) => {
            if(body.error != undefined){
              message.error(body.error)
            }else{
              return body
            }
          })
        break
      case "edit":
        thisfecth = ifetch(`/api/job_template/${this.state.id}`, "JSONPATCH",
          {
            job_template:{
              id:   this.state.id,
              name: this.state.name,
            }
          }).then((body) => {
            if(body.errors != undefined){
              message.error(JSON.stringify(body.errors))
            }else{
              return body
            }
          })
        break
      case "delete":
        thisfecth = ifetch(`/api/job_template/${this.state.id}`, "DELETE")
        break
    }
    thisfecth.then((e) => {
        console.log("eid", e)
        if(e.errors){
          message.error(e.errors)
          return
        }
        if(e.data.id){
          switch(this.state.action){
            case "new":
              message.info("新增成功")
              break
            case "edit":
              message.info("更新成功")
              break
            case "delete":
              message.info("刪除成功")
              break
          }
          this.cleanForm()
          this.setState((p,n) => {
            let newData = []
            let ids = []
            switch(p.action){
              case "new":
                newData = [e.data, ...p.data]
                break
              case "edit":
                //remvoe updated records
                ids = _.chain(p.data)
                              .map((d) => {
                                return d.id
                              }).uniq().value()
                if(_.includes(ids, e.data.id)){
                  newData = _.remove(p.data, (v) => {
                    return v.id != e.data.id
                  })
                }
                newData = [e.data, ...newData]
                break
              case "delete":
                ids = _.chain(p.data)
                              .map((d) => {
                                return d.id
                              }).uniq().value()
                if(_.includes(ids, e.data.id)){
                  newData = _.remove(p.data, (v) => {
                    return v.id != e.data.id
                  })
                }
                break
            }
            return {
              visible: false,
              data: newData,
            }
          })
        }else{
          message.error("新增失敗,請重試")
        }
      }).catch((e) => {
        message.error("操作失敗,請重試")
      })
  }
  cleanForm(){
    this.setState((p, n) => {
      return {
        name: "",
      }
    })
  }
  handleSubmit(e) {

  }
  showModal(e, action) {
    e.preventDefault()
    this.setState((p,n) => {
      return {
        visible: true,
        action
      }
    })
  }
  handleCancel(e) {
    this.setState((p,n) => {
      return {visible: false}
    })
    this.cleanForm()
  }
  setInput(e, type){
    const self = this
    switch (type) {
      case "name":
        self.setState({name: e.target.value})
        break
    }
  }
  render() {
    return (
      <Layout className={["layout", "main_layout"]} style={{ width: '100%', height: '100%' }}>
        <PageHeader />
        <Content className={["main_layout"]} style={{ padding: '0 50px' }}>
          <div style={{ background: '#fff', padding: 24, minHeight: 280 }}>
            <Modal
              visible={this.state.visible}
              title="排程樣板"
              onOk={this.handleOk}
              onCancel={this.handleCancel}
              footer={[
                <Button key="back" size="large" onClick={this.handleCancel}>取消</Button>,
                <Button key="submit" type="primary" size="large" onClick={this.handleOk}>
                  送出
                </Button>,
              ]}
            >
              {
                (this.state.action == "new" || this.state.action == "edit") &&
                  (
                    <Form layout="inline" onSubmit={this.handleSubmit}>
                      <Row>
                        <Col span={2}></Col>
                        <Col span={8}>
                          名稱: <Input placeholder="名稱" value={this.state.name} onChange={(e) => this.setInput(e, "name")} />
                        </Col>
                      </Row>
                    </Form>
                  )
              }
              {
                (this.state.action == "delete") &&
                  (
                    <Alert
                      message="注意!"
                      description="刪除將會連帶節目排程一起刪除,是否確認刪除?"
                      type="error"
                      showIcon
                    />
                  )
              }
            </Modal>
            <Button type="primary" onClick={(e) => this.showModal(e, "new")}>新增排程樣板</Button>
            <Table columns={this.state.columns} dataSource={this.state.data} />
          </div>
        </Content>
      </Layout>
    )
  }
}

var element = document.getElementById('app');
ReactDOM.render(<JobTemplatePage />, element)
