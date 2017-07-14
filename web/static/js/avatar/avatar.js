import { Tabs, Select, Button, Table, Layout, Row, Alert, Form, Breadcrumb, Col, TimePicker, Menu, DatePicker, Input, Modal, message} from 'antd'
const { Header, Content, Footer, Sider } = Layout
const FormItem = Form.Item
const Option = Select.Option
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
        title: '應用端',
        dataIndex: 'name'
      },
      {
        title: '描述',
        dataIndex: 'descript'
      },
      {
        title: '狀態',
        dataIndex: 'status',
        render: (e, record) => {
          return (
            <span>
              {
                record.status == null && "stop"
              }
              {
                record.status != "" && record.status
              }
            </span>
          )
        }
      },
      {
        title: '最後執行時間',
        dataIndex: 'last_exected_time',
        render: (e, record) => {
          return (
            <span>
              {
                record.last_exected_time == null && "無紀錄"
              }
              {
                record.last_exected_time != "" && record.last_exected_time
              }
            </span>
          )
        }
      },
      {
        title: '樣板綁訂',
        dataIndex: 'job_template_id',
        render: (e,record) => {
          return (
            <a href={`/template/${record.job_template_id}`}>{record.template_name}</a>
          )
        }
      },
      {
        title: 'TimeJob',
        dataIndex: 'time_job_id',
      },
      {
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
      jobTemplates: [],
      visible: false,
      id: 0,
      name: '',
      descript: '',
      templateId: 0,
      action: 'new',
    }
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleOk = this.handleOk.bind(this)
    this.showModal = this.showModal.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    this.setInput = this.setInput.bind(this)
    this.cleanForm = this.cleanForm.bind(this)
    this.getUpdate = this.getUpdate.bind(this)
    this.setTemplate = this.setTemplate.bind(this)
    this.showModalNewAvatar = this.showModalNewAvatar.bind(this)
  }
  componentWillMount(){
    ifetch("/api/avatar", "GET").then((e) => {
      this.setState({
        data: e.data,
      })
    })
    ifetch("/api/job_template", "GET").then((e) => {
      this.setState({
        jobTemplates: e.data,
      })
    })
  }
  getUpdate(e) {
    this.setState({
      id: e.id,
      name: e.name,
      descript: e.descript,
      templateId: e.job_template_id
    })
  }
  handleOk(e) {
    if(this.state.name == ""){
      message.error("應用端名稱不可為空白")
    }
    if(this.state.templateId == 0){
      message.error("樣板沒有選擇")
    }
    let thisfecth = ""
    switch (this.state.action) {
      case "new":
        thisfecth = ifetch("/api/avatar", "JSONPOST",
          {
            avatar:{
              name: this.state.name,
              descript: this.state.descript,
              job_template_id: this.state.templateId,
            }
          }).then((body) => {
            if(body.errors != undefined){
              message.error(JSON.stringify(body.errors))
            }else{
              return body
            }
          })
        break
      case "edit":
        thisfecth = ifetch(`/api/avatar/${this.state.id}`, "JSONPATCH",
          {
            avatar:{
              id:   this.state.id,
              name: this.state.name,
              descript: this.state.descript,
              templateId: this.state.templateId,
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
        thisfecth = ifetch(`/api/avatar/${this.state.id}`, "DELETE")
        break
    }
    thisfecth.then((e) => {
        console.log("eid", e)
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
  showModalNewAvatar(e, action) {
    e.preventDefault()
    this.setState((p,n) => {
      return {
        name: "",
        descript: "",
        templateId: null,
        visible: true,
        action
      }
    })
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
      case "descript":
        self.setState({descript: e.target.value})
    }
  }
  setTemplate(e){
    console.log(e)
    this.setState({
      templateId: e,
    })
  }
  render() {
    return (
      <Layout className={["layout", "main_layout"]} style={{ width: '100%', height: '100%' }}>
        <PageHeader />
        <Content className={["main_layout"]} style={{ padding: '0 50px' }}>
          <div style={{ background: '#fff', padding: 24, minHeight: 280 }}>
            <Modal
              visible={this.state.visible}
              title="應用端"
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
                        <Col span={8}>
                          名稱: <Input placeholder="名稱" value={this.state.name} onChange={(e) => this.setInput(e, "name")} />
                          敘述: <Input placeholder="敘述" value={this.state.descript} onChange={(e) => this.setInput(e, "descript")} />
                        </Col>
                      </Row>
                      <Row className={"_creat_modal_row"}>
                        <Col span={3}>
                          <div style={{margin: '3px'}}>選擇樣板:</div>
                        </Col>
                        <Col span={15}>
                          <Select
                            value={this.state.templateId}
                            style={{ width: 120 }}
                            onChange={this.setTemplate}>
                            {
                              this.state.jobTemplates.map((object) => {
                                return (<Option key={object.id} value={object.id}>{object.name}</Option>)
                              })
                            }
                          </Select>
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
                      description="刪除可能造成該應用端服務停止,是否確認刪除?"
                      type="error"
                      showIcon
                    />
                  )
              }
            </Modal>
            <Button type="primary" onClick={(e) => this.showModalNewAvatar(e, "new")}>建立應用端</Button>
            <Table columns={this.state.columns} dataSource={this.state.data} />
          </div>
        </Content>
      </Layout>
    )
  }
}

var element = document.getElementById('app');
ReactDOM.render(<JobTemplatePage />, element)
