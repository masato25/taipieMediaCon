import { Button, Tabs, Layout, Row, Breadcrumb, Col, Select, TimePicker, Menu, DatePicker, Input, Modal, message} from 'antd'
const { Header, Content, Footer, Sider } = Layout
const confirm = Modal.confirm
const TabPane = Tabs.TabPane
import ReactDOM from 'react-dom'
import React from 'react'
import PropTypes from 'prop-types'
import BigCalendar from 'react-big-calendar'
import moment from 'moment'
import {JobSetter} from './component/job_setter2.js'
import "./css/f_calendar.css"
import {PageHeader} from "../common/page_header.js"
import ifetch from '../common/fetch.js'

const $ = require('jquery')
const _ = require('lodash')
BigCalendar.setLocalizer(
  BigCalendar.momentLocalizer(moment)
)

const format = 'HH:mm'

class MainTest extends React.Component {
  constructor(props) {
    super(props);
    this.moment = moment
    this.ifetch = ifetch
    //a temp place for store a temp value
    this.ptmp = ""
    this.state = {
      id: 0,
      events: [],
			defaultDate: new Date(moment().subtract(3, 'day')._d),
      format: 'HH:mm',
			culture: 'zh-TW',
      updateObj: {
        date: '',
        stime: '',
        etime: '',
        program_id: 0
      },
      errorMsg: "",
      visible: false,
      programs: [],
    }
    this.showConfirm = this.showConfirm.bind(this)
    this.setDate = this.setDate.bind(this)
    this.setStime = this.setStime.bind(this)
    this.setEtime = this.setEtime.bind(this)
    this.setPorgram = this.setPorgram.bind(this)
    this.addJob = this.addJob.bind(this)
  }
  callback(e) {
  	console.log(e)
  }
	clickTime(e) {
		console.log(e)
	}
  componentWillMount() {
    const self = this
    ifetch("/api/time_jobs_list", 'GET').then((e) => {
      const newEvenet = _.map(e.data, (a) => {
        return {
          start: new Date(a.start_time * 1000),
          end:  new Date(a.end_time * 1000),
          title: a.title,
          id: a.id,
        }
      })
      self.newEvenet = newEvenet
      self.setState({
        events: self.newEvenet
      })
    })
    ifetch("/api/program", "GET").then((e) => {
      self.setState({
        programs: e.data,
      })
    })
  }
  componentDidMount() {
  }
  setDate(s) {
    //let updateObj = _.merge(this.state.updateObj,{date1: s.formart("YYYY-MM-D")})
    this.ptmp = {date: s.format("YYYY-MM-D")}
    this.setState((pervious, props) => {
      return {
        updateObj: Object.assign({}, pervious.updateObj, this.ptmp)
      }
    })
  }
  setStime(s) {
    this.ptmp = {stime: s.format("HH:mm")}
    this.setState((pervious, props) => {
      return {
        updateObj: Object.assign({}, pervious.updateObj, this.ptmp)
      }
    })
  }
  setEtime(s){
    this.ptmp = {etime: s.format("HH:mm")}
    this.setState((pervious, props) => {
      return {
        updateObj: Object.assign({}, pervious.updateObj, this.ptmp)
      }
    })
  }
  setPorgram(s){
    this.ptmp = {program_id: s}
    this.setState((pervious, props) => {
      return {
        updateObj: Object.assign({}, pervious.updateObj, this.ptmp)
      }
    })
  }
  addJob(e){
    const self = this
    const obj = this.state.updateObj
    const stimeStr = `${obj.date} ${obj.stime}:01`
    const etimeStr = `${obj.date} ${obj.etime}:00`
    const postparm = {
      time_job: {
        start_time: this.moment(stimeStr).unix(),
        end_time: this.moment(etimeStr).unix(),
        program_id: obj.program_id,
      },
    }
    if (this.state.updateObj.program_id === 0) {
      message.error("展示節目為必選選項")
    } else if (+postparm.time_job.start_time >= +postparm.time_job.end_time) {
      message.error("開始時間不可大於結束時間")
    } else {
      self.ifetch("/api/time_jobs_create", 'JSONPOST', postparm).then((e) => {
        console.log("resp:", e)
        if(e.error){
          message.error(e.error)
        }else{
          message.success(e.info)
          self.props = {
            start: new Date(e.event.start_time * 1000),
            end:  new Date(e.event.end_time * 1000),
            title: e.event.title,
            id: e.event.id,
          }
          self.setState((pervious, n) => {
            return {
              events: [self.props, ...pervious.events]
            }
          })
          self.setState((pervious, n) => {
            return ({visible: false})
          })
        }
      })
    }
  }
  showConfirm(e) {
    const self = this
    const pickedD = moment(e.start)
    const pickedDE = moment(e.end)
    self.setDate(pickedD)
    self.setStime(pickedD)
    self.setEtime(pickedDE)
    self.setState((pervious, n) => {
      return ({visible: true})
    })
    confirm({
      title: '請選擇時間',
      okText: 'ok',
      visible: self.state.visible,
      content: (
        <Tabs defaultActiveKey="1" onChange={(e) => console.log(e)}>
          <TabPane tab="建立節目" key="1">
            <Row>
              <Col span={20}>
                <DatePicker defaultValue={pickedD} onChange={self.setDate}/>
              </Col>
              <Col span={10}>
                <TimePicker placeholder={"please select a time"} onChange={self.setStime} defaultValue={pickedD} format={format} />
              </Col>
              <Col span={10}>
                <TimePicker placeholder={"please select a time"} onChange={self.setEtime} defaultValue={pickedDE} format={format} />
              </Col>
              <Col span={20}>
                <Select style={{ width: 120 }} onChange={self.setPorgram}>
                  {
                    this.state.programs.map((object) => {
                      return (<Option value={object.id}>{object.name}</Option>)
                    })
                  }
                </Select>
              </Col>
            </Row>
          </TabPane>
          <TabPane tab="拷貝至下小時" key="2">
            <Row>
              <Col span={20}>
                <DatePicker defaultValue={pickedD}/>
              </Col>
              <Col span={10}>
                <TimePicker placeholder={"please select a time"} defaultValue={pickedDE} format={format} />
              </Col>
            </Row>
          </TabPane>
        </Tabs>
      ),
      cancelText: 'cancel',
      onOk(e) {
        self.addJob(e)
        self.setState((pervious, n) => {
          return ({visible: false})
        })
      },
      onCancel() {
        console.log('Cancel')
        self.setState((pervious, n) => {
          return ({visible: false})
        })
      },
    });
  }
  render() {
    return (
      <Layout className={["layout", "main_layout"]} style={{ width: '100%', height: '100%' }}>
        <PageHeader />
        <JobSetter addJob={this.callback}></JobSetter>
        <BigCalendar
          {...this.props}
          formats={{
            dateFormat: 'DD',
            dayFormat: 'MM/DD (ddd)',
            weekdayFormat: 'ddd MM/DD',
          }}
          events={this.state.events}
          defaultView='week' defaultDate={this.state.defaultDate}
					culture={this.state.culture}
					views={['month', 'week', 'day']}
					onSelectSlot={e => this.showConfirm(e)}
					onSelectEvent={event => console.log(event)}
          onShowMore={event => console.log(event)}
					selectable
          className="_bigcal"
          messages={{
            next: "往前",
            today: "本日",
            previous: "往後",
            month: "月",
            week: "周",
            day: "日",
          }}
        />
     </Layout>
    )
  }
}

var element = document.getElementById('app');
ReactDOM.render(<MainTest />, element)
