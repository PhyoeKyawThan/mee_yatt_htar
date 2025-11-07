# from .tracker import Tracker
from models import db, Employee, Change
from sqlalchemy import select
from datetime import datetime
import os
from werkzeug.datastructures import FileStorage

class Sync:
    _device: str
    _changed_data: dict
    images: list[FileStorage]
    UPLOAD_DIR: str
    separated_data: dict = {
        "create" : [],
        "update" : [],
        "delete" : [],
    }
    
    def __init__(self, changed_data: dict, images: list[FileStorage], upload_dir: str) -> None:
        if len(changed_data['changes']) <= 0:
            self._changed_data = None
        else:
            self._device = changed_data['device']
            self._changed_data = changed_data['changes']
            self._separate()
            self.images = images
            self.UPLOAD_DIR = upload_dir
    
    def _separate(self) -> None:
        for d in self._changed_data:
            if d['type'] in self.separated_data.keys():
                self.separated_data[d['type']].append(d['data'])
    
    def apply_changes(self) -> bool:
        for type in self.separated_data.keys():
            self._changes_mapper(type, self.separated_data[type])
        db.session.query(Change).delete()
        db.session.commit()
    
    def _changes_mapper(self, type: str, data: list):
        if type == "create":
            for emp in data:
                if emp:
                    self._do_create(emp)
        if type  == "update":
            for emp in data:
                if emp:
                    self._do_update(emp)
        if type == "delete":
            for emp in data:
                if emp:
                    self._do_delete(emp)
    
    def _do_delete(self, employee_id: int) -> None:
        emp = Employee.query.get(employee_id)
        if emp:
            db.session.delete(emp)
            db.session.commit()
        
    def _do_create(self, employee_data: dict) -> None:
        for image in self.images:
            if image.filename == os.path.basename(employee_data['imagePath']):
                image.save(os.path.join(self.UPLOAD_DIR, image.filename))
                break
        db.session.add(self._convert_to_obj(employee_data))
        db.session.commit()
        
    # def _check_conflict(self) -> Employee | None:
    #     changes = db.session.execute(select(Change).filter(Change.type == "update")).scalars().all()
    #     if changes:
    #         for ch in changes:
    #             for temp in self.separated_data['update']:
    #                 if ch.emp_id == temp.emp_id:
                        
    #     return Employee()
    def _do_update(self, employee_data: dict) -> None:
        emp = Employee.query.get(employee_data.get('id'))
        if not emp:
            print(f"No employee found with ID {employee_data.get('id')}")
            return

        emp.fullName = employee_data.get("fullName", emp.fullName)
        emp.gender = employee_data.get("gender", emp.gender)
        emp.fatherName = employee_data.get("fatherName", emp.fatherName)
        emp.motherName = employee_data.get("motherName", emp.motherName)
        emp.nrcNumber = employee_data.get("nrcNumber", emp.nrcNumber)
        emp.dateOfBirth = employee_data.get("dateOfBirth", emp.dateOfBirth)
        emp.age = employee_data.get("age", emp.age)
        emp.educationLevel = employee_data.get("educationLevel", emp.educationLevel)
        emp.educationDesc = employee_data.get("educationDesc", emp.educationDesc)
        emp.bloodType = employee_data.get("bloodType", emp.bloodType)
        emp.address = employee_data.get("address", emp.address)
        emp.assignedBranch = employee_data.get("assignedBranch", emp.assignedBranch)
        emp.firstAssignedPosition = employee_data.get("firstAssignedPosition", emp.firstAssignedPosition)
        emp.firstAssignedDate = employee_data.get("firstAssignedDate", emp.firstAssignedDate)
        emp.currentPosition = employee_data.get("currentPosition", emp.currentPosition)
        emp.currentSalaryRange = employee_data.get("currentSalaryRange", emp.currentSalaryRange)
        emp.currentPositionAssignDate = employee_data.get("currentPositionAssignDate", emp.currentPositionAssignDate)
        emp.currentSalary = employee_data.get("currentSalary", emp.currentSalary)
        emp.trainingCourses = employee_data.get("trainingCourses", emp.trainingCourses)
        emp.remarks = employee_data.get("remarks", emp.remarks)
        emp.imagePath = employee_data.get("imagePath", emp.imagePath)
        # emp.syncId = employee_data.get("syncId", emp.syncId)
        emp.updatedAt = datetime.utcnow()
        
        # if(os.path.exists(os.path.join(self.UPLOAD_DIR, employee_data.get('imagePath'))) == False):
        for image in self.images:
            if image.filename == os.path.basename(employee_data['imagePath']):
                image.save(os.path.join(self.UPLOAD_DIR, image.filename))
                break
        db.session.commit()
        
    def _convert_to_obj(self, employee: dict) -> "Employee":
        emp = Employee()

        emp.id = employee.get("id")
        emp.fullName = employee.get("fullName")
        emp.gender = employee.get("gender")
        emp.fatherName = employee.get("fatherName")
        emp.motherName = employee.get("motherName")
        emp.nrcNumber = employee.get("nrcNumber")
        emp.dateOfBirth = employee.get("dateOfBirth")
        emp.age = employee.get("age")
        emp.educationLevel = employee.get("educationLevel")
        emp.educationDesc = employee.get("educationDesc")
        emp.bloodType = employee.get("bloodType")
        emp.address = employee.get("address")
        emp.assignedBranch = employee.get("assignedBranch")
        emp.firstAssignedPosition = employee.get("firstAssignedPosition")
        emp.firstAssignedDate = employee.get("firstAssignedDate")
        emp.currentPosition = employee.get("currentPosition")
        emp.currentSalaryRange = employee.get("currentSalaryRange")
        emp.currentPositionAssignDate = employee.get("currentPositionAssignDate")
        emp.currentSalary = employee.get("currentSalary")
        emp.trainingCourses = employee.get("trainingCourses")
        emp.remarks = employee.get("remarks")
        emp.imagePath = employee.get("imagePath")
        # emp.syncId = employee.get("syncId")

        created = employee.get("createdAt")
        updated = employee.get("updatedAt")
        if created:
            try:
                emp.createdAt = datetime.fromisoformat(created)
            except Exception:
                emp.createdAt = datetime.utcnow()
        if updated:
            try:
                emp.updatedAt = datetime.fromisoformat(updated)
            except Exception:
                emp.updatedAt = datetime.utcnow()

        return emp
        
        