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
import {ModalAddJob} from './component/modal_add_job.js'
import {getDefaultData, addJobAction, handleCancel_AddAction,
        handleLOk_AddAction, showModalAddAction, setPorgramAction,
        setEtimeAction, setStimeAction, setDateAction,
        deleteJobAction, setAddAction_Action,copyJobsAction_Action, 
        getTemplateId, getTemplateName} from './actions/actions.js'
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
    this.messageComp = message
    //a temp place for store a temp value
    this.ptmp = ""
    this.state = {
      id: 0,
      events: [],
			defaultDate: new Date(moment().subtract(3, 'day')._d),
      format: 'HH:mm',
			culture: 'zh-TW',
      visibleAdd: false,
      errorMsg: "",
      visible: false,
      pickedD: null,
      pickedDE: null,
      programs: [],
      addAction: "add",
      copyToHour: 1,
      template_id: parseInt(getTemplateId()),
      templateName: "未知",
      updateObj: {
        date: '',
        stime: '',
        etime: '',
        program_id: 0
      },
    }
    getTemplateName().then((e) => {
      this.state.templateName = e.data.name
    })
    this.showModalAdd = this.showModalAdd.bind(this)
    this.setDate = this.setDate.bind(this)
    this.setStime = this.setStime.bind(this)
    this.setEtime = this.setEtime.bind(this)
    this.setPorgram = this.setPorgram.bind(this)
    this.addJob = this.addJob.bind(this)
    this.handleCancel_Add = this.handleCancel_Add.bind(this)
    this.handleLOk_Add = this.handleLOk_Add.bind(this)
    this.triggerdeleteMal = this.triggerdeleteMal.bind(this)
    this.deleteJob = this.deleteJob.bind(this)
    this.setAddAction = this.setAddAction.bind(this)
    this.setcopyToHour = this.setcopyToHour.bind(this)
    this.copyJobsAction = this.copyJobsAction.bind(this)
    this.pushDataToEvents = this.pushDataToEvents.bind(this)
    this.deleteEvents = this.deleteEvents.bind(this)
  }
  callback(e) {
  	console.log(e)
  }
	clickTime(e) {
		console.log(e)
	}
  componentWillMount() {
    getDefaultData(this)
  }
  componentDidMount() {
  }
  triggerdeleteMal(e){
    const self = this
    self.ptmp = e
    confirm({
      title: '確認要刪除？',
      content: `將會刪除`,
      onOk: self.deleteJob,
      onCancel() {
        console.log('Cancel');
      },
    })
  }
  deleteJob(){
    deleteJobAction(this)
  }
  addJob(e){
    addJobAction(e, this)
  }
  setDate(s) {
    setDateAction(s, this)
  }
  setStime(s) {
    setStimeAction(s, this)
  }
  setEtime(s){
    setEtimeAction(s, this)
  }
  setPorgram(s){
    setPorgramAction(s, this)
  }
  showModalAdd(e) {
    showModalAddAction(e, this)
  }
  handleLOk_Add(e) {
    handleLOk_AddAction(e, this)
  }
  handleCancel_Add(e){
    handleCancel_AddAction(e, this)
  }
  setAddAction(e){
    setAddAction_Action(e, this)
  }
  setcopyToHour(e){
    this.setState({copyToHour: e})
  }
  copyJobsAction(){
    copyJobsAction_Action(this)
  }
  pushDataToEvents(data){
    const self = this
    const newEvenet = _.map(data, (a) => {
      return {
        start: new Date(a.start_time * 1000),
        end:  new Date(a.end_time * 1000),
        title: a.title,
        id: a.id,
      }
    })
    self.setState((pervious,n) => {
      return {
        events: pervious.events.concat(newEvenet)
      }
    })
  }
  deleteEvents(data){
    const self = this
    self.setState((pervious,n) => {
      const newEvents = _.remove(pervious.events, (v) => {
        return !_.includes(data,v.id)
      })
      return {
        events: newEvents
      }
    })
  }
  render() {
    return (
      <Layout className={["layout", "main_layout"]} style={{ width: '100%', height: '100%' }}>
        <PageHeader />
        <JobSetter
          addJob={this.callback}
          pushDataToEvents={this.pushDataToEvents}
          deleteEvents={this.deleteEvents}
          job_template_id = {this.state.template_id}
          templateName = {this.state.templateName}
        ></JobSetter>
        <ModalAddJob
          visible={this.state.visibleAdd}
          handleOk={this.handleLOk_Add}
          handleCancel={this.handleCancel_Add}
          pickedD={this.state.pickedD}
          pickedDE={this.state.pickedDE}
          setDate={this.setDate}
          setStime={this.setStime}
          setEtime={this.setEtime}
          setPorgram={this.setPorgram}
          programs={this.state.programs}
          setAddAction={this.setAddAction}
          setcopyToHour={this.setcopyToHour}
          copyToHour={this.state.copyToHour}
        />
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
					onSelectSlot={e => this.showModalAdd(e)}
					onSelectEvent={event => this.triggerdeleteMal(event)}
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
