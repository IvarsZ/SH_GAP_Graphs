f := function(t)
  Sleep(t);
  return t;  
end;

tasks := [];
for t in [2, 4, 2, 6, 7] do
  task := RunTask(f, t);
  Add(tasks, task);
od;

while Length(tasks) > 0 do
  taskIndex := WaitAnyTask(tasks);
  task := tasks[taskIndex];
  Print(TaskResult(task), "\n");
  #Remove(tasks, taskIndex);
od;

