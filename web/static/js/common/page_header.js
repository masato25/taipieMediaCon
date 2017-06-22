import React from 'react';
import { Layout, Breadcrumb, DatePicker, Table, Icon, Row, Col, Card, Tag, Tooltip, Menu} from 'antd';
const { Header, Content, Footer } = Layout;

class PageHeader extends React.Component {
  render () {
    return (
      <Header className="header">
        <div className="logo" />
        <Menu
          theme="dark"
          mode="horizontal"
          defaultSelectedKeys={['2']}
          style={{ lineHeight: '64px' }}
        >
          <Menu.Item key="1">
            互動展示系統<Icon type="smile-o"/>
          </Menu.Item>
          <Menu.Item key="2"><a href="/template">播放模板</a></Menu.Item>
          <Menu.Item key="4"><a href="/program">節目列表</a></Menu.Item>
          <Menu.Item key="3"><a href="/avatar">應用端管理</a></Menu.Item>
          <Menu.Item key="5"><a href="/logout">登出</a></Menu.Item>
        </Menu>
      </Header>
    )
  }
}

module.exports = {PageHeader}
