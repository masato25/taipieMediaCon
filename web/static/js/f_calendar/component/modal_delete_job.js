import { Button, Icon, Tabs, Layout, Row, Breadcrumb, Col, Select, TimePicker, Menu, DatePicker, Input, Modal, message} from 'antd'
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

const ModalDeleteJob = (obj, self) => {
  return ({
    title: '確認要刪除？',
    content: `將會刪除`,
    onOk() {
      console.log('OK', obj);
      debugger
    },
    onCancel() {
      console.log('Cancel');
    },
  })
}

module.exports = {ModalDeleteJob}
