from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import enum
from sqlalchemy import Enum
from sqlalchemy.orm import Mapped
db = SQLAlchemy()

class Employee(db.Model):
    __tablename__ = 'employees'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    fullName = db.Column(db.String(255), nullable=False)
    gender = db.Column(db.String(50))
    fatherName = db.Column(db.String(255))
    motherName = db.Column(db.String(255))
    nrcNumber = db.Column(db.String(100))
    dateOfBirth = db.Column(db.String(100))
    age = db.Column(db.Integer)
    educationLevel = db.Column(db.String(255))
    educationDesc = db.Column(db.Text)
    bloodType = db.Column(db.String(10))
    address = db.Column(db.Text)
    assignedBranch = db.Column(db.String(255))
    firstAssignedPosition = db.Column(db.String(255))
    firstAssignedDate = db.Column(db.String(100))
    currentPosition = db.Column(db.String(255))
    currentSalaryRange = db.Column(db.String(255))
    currentPositionAssignDate = db.Column(db.String(100))
    currentSalary = db.Column(db.String(100))
    trainingCourses = db.Column(db.Text)
    remarks = db.Column(db.Text)
    imagePath = db.Column(db.Text)
    # syncId = db.Column(db.String(100), unique=True)
    createdAt = db.Column(db.TIMESTAMP, default=datetime.utcnow)
    updatedAt = db.Column(db.TIMESTAMP, default=datetime.utcnow, onupdate=datetime.utcnow)
    # change = db.relationship('Change', back_populates='employee')
    
    def __repr__(self):
        return f"<Employee {self.id} - {self.fullName}>"

    def to_dict(self):
        """Convert model instance to a dictionary (for JSON serialization)."""
        return {
            "id": self.id,
            "fullName": self.fullName,
            "gender": self.gender,
            "fatherName": self.fatherName,
            "motherName": self.motherName,
            "nrcNumber": self.nrcNumber,
            "dateOfBirth": self.dateOfBirth,
            "age": self.age,
            "educationLevel": self.educationLevel,
            "educationDesc": self.educationDesc,
            "bloodType": self.bloodType,
            "address": self.address,
            "assignedBranch": self.assignedBranch,
            "firstAssignedPosition": self.firstAssignedPosition,
            "firstAssignedDate": self.firstAssignedDate,
            "currentPosition": self.currentPosition,
            "currentSalaryRange": self.currentSalaryRange,
            "currentPositionAssignDate": self.currentPositionAssignDate,
            "currentSalary": self.currentSalary,
            "trainingCourses": self.trainingCourses,
            "remarks": self.remarks,
            "imagePath": self.imagePath,
            "createdAt": self.createdAt.isoformat() if self.createdAt else None,
            "updatedAt": self.updatedAt.isoformat() if self.updatedAt else None
        }

class Types(enum.Enum):
    create: str = "create"
    update: str = "update"
    delete: str = "delete"
    

class Change(db.Model):
    __tablename__ = "changes"
    
    id: Mapped[int] = db.Column(db.Integer, primary_key=True, autoincrement=True)
    type: Mapped[Types] = db.Column(Enum(Types, nullable=False))
    emp_id: Mapped[int] = db.Column(db.Integer, nullable=False)
    
    def __repr__(self):
        return f"<Change {self.emp_id}> - {self.employee}>"
    
    def to_dict(self):
        employee: Employee = Employee.query.get(self.emp_id)
        if employee:
            return {
                "type": "update" if self.type.update else "delete" if self.type.delete else "create",
                "data": employee.to_dict()
            }