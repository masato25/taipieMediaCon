const _ = require('lodash')

const getTemplateId = () => {
  let jid = window.location.href.match(/template\/(\d+)$/i) || ["","0"]
  return jid[1]
}
const getDefaultData = (self) => {
  let jid = getTemplateId()
  self.ifetch(`/api/time_jobs_list/${jid}`, 'GET').then((e) => {
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
  self.ifetch("/api/program", "GET").then((e) => {
    self.setState({
      programs: e.data,
    })
  })
}

const deleteJobAction = (self) => {
  const obj = self.ptmp
  self.ifetch(`/api/time_jobs/${obj.id}`, "DELETE").then((e) => {
    if (e.error) {
      self.messageComp.error(e.error)
    } else if (e.errors) {
      self.messageComp.error(e.errors)
    } else {
      self.messageComp.success("刪除成功")
      self.setState((p, n) => {
        const newEvent = _.remove(p.events, (v) => {
          return v.id != e.data.id
        })
        return {
          events: newEvent,
        }
      })
    }
  })
}

const addJobAction = (e, self) => {
  const obj = self.state.updateObj
  const stimeStr = `${obj.date} ${obj.stime}:01`
  const etimeStr = `${obj.date} ${obj.etime}:00`
  let jid = getTemplateId()
  const postparm = {
    time_job: {
      start_time: self.moment(stimeStr).unix(),
      end_time: self.moment(etimeStr).unix(),
      program_id: obj.program_id,
      job_template_id: parseInt(jid),
    },
  }
  if (self.state.updateObj.program_id === 0) {
    self.messageComp.error("展示節目為必選選項")
  } else if (+postparm.time_job.start_time >= +postparm.time_job.end_time) {
    self.messageComp.error("開始時間不可大於結束時間")
  } else {
    self.ifetch("/api/time_jobs_create", 'JSONPOST', postparm).then((e) => {
      console.log("resp:", e)
      if(e.error){
        self.messageComp.error(e.error)
      }else{
        self.messageComp.success(e.info)
        self.props = {
          start: new Date(e.event.start_time * 1000),
          end:  new Date(e.event.end_time * 1000),
          title: e.event.title,
          id: e.event.id,
          job_template_id: e.event.job_template_id,
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

const setDateAction = (s, self) => {
  const pickedD = self.moment(`${s.format("YYYY-MM-D")} ${self.state.pickedD.format("HH:mm")}`, "YYYY-MM-D HH:mm")
  self.ptmp = {date: s.format("YYYY-MM-D"), pickedD: pickedD}
  self.setState((pervious, props) => {
    return {
      pickedD: self.ptmp.pickedD,
      updateObj: Object.assign({}, pervious.updateObj, {date: self.ptmp.date}),
    }
  })
}

const setStimeAction = (s, self) => {
  const pickedD = self.moment(`${self.state.pickedD.format("YYYY-MM-D")} ${s.format("HH:mm")}`, "YYYY-MM-D HH:mm")
  self.ptmp = {stime: s.format("HH:mm"), pickedD: pickedD}
  self.setState((pervious, props) => {
    return {
      pickedD: self.ptmp.pickedD,
      updateObj: Object.assign({}, pervious.updateObj, {stime: self.ptmp.stime})
    }
  })
}
const setEtimeAction = (s, self) => {
  const pickedDE = self.moment(`${self.state.pickedDE.format("YYYY-MM-D")} ${s.format("HH:mm")}`, "YYYY-MM-D HH:mm")
  self.ptmp = {etime: s.format("HH:mm"), pickedDE: pickedDE}
  self.setState((pervious, props) => {
    return {
      pickedDE: self.ptmp.pickedDE,
      updateObj: Object.assign({}, pervious.updateObj, {etime: self.ptmp.etime}),
    }
  })
}
const setPorgramAction = (s, self) => {
  self.ptmp = {program_id: s}
  self.setState((pervious, props) => {
    return {
      updateObj: Object.assign({}, pervious.updateObj, self.ptmp)
    }
  })
}
const showModalAddAction = (e, self) =>  {
  const pickedD = self.moment(e.start)
  const pickedDE = self.moment(e.end)
  self.setState({
    visibleAdd: true,
    pickedD,
    pickedDE,
  })
  self.setDate(pickedD)
  self.setStime(pickedD)
  self.setEtime(pickedDE)
}
const handleLOk_AddAction = (e, self) => {
  if(self.state.addAction == "add"){
    self.addJob(e)
    self.setState((pervious, n) => {
      return ({visibleAdd: false})
    })
  }
  if(self.state.addAction == "copy"){
    self.copyJobsAction()
  }
}

const copyJobsAction_Action = (self) => {
  if (isNaN(parseInt(self.state.copyToHour))) {
    self.messageComp.error("拷貝至必須為數字")
    return
  }
  const stime = self.moment(self.state.pickedD.format("YYYY-MM-D HH")).unix()

  self.ifetch("/api/time_jobs_copy_hour", 'JSONPOST', {
    start_time: stime,
    end_time: stime + (60*60),
    copy_next_h: parseInt(self.state.copyToHour),
    job_template_id: parseInt(getTemplateId()),
  }).then((e) => {
    self.messageComp.info("拷貝成功")
    const newEvenet = _.map(e.data, (a) => {
      return {
        start: new Date(a.start_time * 1000),
        end:  new Date(a.end_time * 1000),
        title: a.title,
        id: a.id,
        job_template_id: a.job_template_id,
      }
    })
    self.setState((pervious,n) => {
      return {
        events: pervious.events.concat(newEvenet)
      }
    })
  }).catch((e) => {
    self.messageComp.error("拷貝失敗請重試")
  })
}

const handleCancel_AddAction = (e, self) => {
  self.setState((pervious, n) => {
    return ({visibleAdd: false})
  })
}

const setAddAction_Action = (e, self) => {
  switch(e){
    case '1':
      self.setState((p,n) => {
        return {addAction: "add"}
      })
      break
    case '2':
      self.setState((p,n) => {
        return {addAction: "copy"}
      })
      break
  }
}

module.exports = {
  getDefaultData,
  addJobAction,
  handleCancel_AddAction,
  handleLOk_AddAction,
  showModalAddAction,
  setPorgramAction,
  setEtimeAction,
  setStimeAction,
  setDateAction,
  deleteJobAction,
  setAddAction_Action,
  copyJobsAction_Action,
  getTemplateId,
}
