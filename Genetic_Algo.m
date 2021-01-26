%%Homework Assignment 4
%%Genetic algorithm - Shashank Iyengar, Johann Koshy

clear all
close all
clc
set(0,'DefaultAxesFontName', 'Calibri')
set(0,'DefaultAxesFontSize', 11)
set(0,'defaultlinelinewidth',1)
set(0,'DefaultLineMarkerSize', 8)
set(0,'defaultAxesFontWeight','bold')

prompt = 'Enter number of cities: ';
N = input(prompt);

% Create Cities
x = rand(1,N)*100
y = rand(1,N)*100
z = 1;                          % To track global minimum
gen_count = [];                 % To track generation at which min is obtained

% Selecting first population
if mod(N,2)==0                  % Controlling population length
    pop_length = N;
else
    pop_length = N-1;
end
pop = [];
for i=1:pop_length
    pop(i,2:N) = randperm(N-1);
    for j=1:N
        if pop(i,j)==1
            pop(i,j) = N;
        end
    end
end
for i=1:pop_length
    pop(i,1) = 1;               % Starting and ending with the same city
    pop(i,N+1) = 1;
end
pop
pop_length = length(pop(:,1));
parent_pop = pop;
min_global = 10000;

for gen=1:1500                  % Number of generations
    
% Creating Random order before crossover for introducing randomness in crossover   
l = randperm(pop_length,pop_length);   % Random order for new population
pop_swap = pop;
for i=1:length(pop(:,1))
    pop([i l(i)],:) = pop_swap([l(i) i],:);
end
if gen==250 && gen==500 && gen==750    % Gene Flow - Introducing four new individuals for genetic diversity at gen 500
    for i=1:round(N/5)
        pop(i,2:N) = randperm(N-1);
        for j=1:N
            if pop(i,j)==1
                pop(i,j) = N;
            end
        end
    end
    for i=1:round(N/5)
        pop(i,1) = 1;
        pop(i,N+1) = 1;
    end
end
pop;
gen;


% Crossover PMX
% Determining selection for index for slicing
if gen<300
    start_slice = round(0.35*(N+1));
    stop_slice = round(0.65*(N+1));
else if gen<500
        start_slice = round(0.25*(N+1));
        stop_slice = round(0.75*(N+1));
    else
        start_slice = round((0.5-0.5*rand(1))*(N+1))+1;
        stop_slice = round((0.5+0.5*rand(1))*(N+1))-1;
    end
end
dummy=[];
r=0;

for i=1:2:(length(pop(:,1)))        
   dummy(i,:) = pop(i,start_slice:stop_slice);
   dummy(i+1,:) = pop(i+1,start_slice:stop_slice);
   o = stop_slice-start_slice+1;
   % To check if numbers are repeated and swap them
   for j=1:o
       for k=1:o
            if dummy(i,j)==dummy(i+1,k)  % To check if the slice has same numbers swapped
                dummy(i,j) = 0;
                dummy(i+1,k) = 0;
            end
       end
   end
   n = 1;
   for j=1:o
       if dummy(i,j)~=0                    %% To check if the slice has same numbers swapped
           for w=1:N+1                     %% To search the population for repeating elements from crossover chromosomes
               if dummy(i,j)==pop(i+1,w)   %% To search the population for repeating elements from crossover chromosomes
                   for u=n:o
                       if dummy(i+1,u)~=0 && r==0 %% To search the population for repeating elements from crossover chromosomes
                            pop(i+1,w)=dummy(i+1,u);
                            r=1;           %% To exit search after replacing the city
                            n=u+1;         %% To start searching dummy variable from that element for next iteration
                            if w==1         %% If first element is swapped last element should be swapped too
                               pop(i+1,N+1)=dummy(i+1,u);
                            end
                       end
                   end
                   r=0;
               end
           end
       end
   end
   
   % Swapping for the second child
   n=1;
      for j=1:o
       if dummy(i+1,j)~=0                  %% To check if the slice has same numbers swapped
           for w=1:N+1                     %% To search the population for repeating elements from crossover chromosomes
               if dummy(i+1,j)==pop(i,w)   %% To search the population for repeating elements from crossover chromosomes
                   for u=n:o
                       if dummy(i,u)~=0 && r==0 %% To search the population for repeating elements from crossover chromosomes
                            pop(i,w)=dummy(i,u);
                            r=1;           %% To exit search after replacing the city
                            n=u+1;         %% To start searching dummy variable from that element for next iteration
                            if w==1        %% If first element is swapped last element should be swapped too
                               pop(i,N+1)=dummy(i,u); 
                            end
                       end
                   end
                   r=0;
               end
           end
       end
   end
   pop([i (i+1)],start_slice:stop_slice)=pop([(i+1) i],start_slice:stop_slice);
end
pop;


% Mutation 
if gen<500
    P_mutation = 0.2;           % Probability of Mutation
else if gen<1000
    P_mutation = 0.3;           % Probability of Mutation
    else
    P_mutation = 0.6;           % Probability of Mutation
    end
end

for i=1:pop_length
    p = rand(1);
    if p<P_mutation
        i;
        swap_mutation_1 = randi([2 N]);
        swap_mutation_2 = randi([2 N]);
        if swap_mutation_2==swap_mutation_2
            swap_mutation_2 = randi([2 N]);
        end
        pop(i,[swap_mutation_1 swap_mutation_2])=pop(i,[swap_mutation_2 swap_mutation_1]);
    end
end

% Adding Children created to population
pop = [parent_pop;pop];


% Computing Fitness for each variable
sum_dist = [];
X = [];
for i=1:length(pop(:,1))
    for j=1:N
        a = pop(i,j); %%City 1 
        b = pop(i,j+1);%% City2
        X = [x(a),y(a);x(b),y(b)];
        dist(j) = pdist(X,'euclidean');
    end
    sum_dist(i) = sum(dist);
    [min_dist best_chromosome] = min(sum_dist); % Indexing min from population
end
totalsum_dist = sum(sum_dist);

for i=1:(length(pop(:,1)))
    fitness(i) = sum_dist(i)/totalsum_dist;
end
fitness;

% Tracking global minimum and path
if min_dist<min_global
    min_globalplot(z) = min_dist;
    best_route = pop(best_chromosome,:);
    min_global = min_dist;
    gen_count(z) = gen;
    z = z+1;
end
newpop = [];

% Ordering matrix according to fitness
for j=1:length(pop(:,1))/2
    [e i] = min(fitness(1:length(pop(:,1))));
    fitness(i) = 1;
    newpop(j,:) = pop(i,:);
end

% Assigning next Generation
pop = newpop;
parent_pop = pop;
% Plotting best route
x1 = [];
y1 = [];
for i=1:N+1
x1(i) = x(best_route(i));
y1(i) = y(best_route(i));
hold on
end

end

best_route
scatter(x,y)
hold on
plot(x(1),y(1),'*k')        % Starting City
hold on
plot(x1,y1,'-r')            % Optimal Route
grid on
title('GA for Traveling Salesman Problem - Optimal Route')
xlabel('x')
ylabel('y')
legend('Cities','Starting City','Optimal Path')
xlim([0 100])
ylim([0 100])
figure
plot(gen_count,min_globalplot,'-ob')
grid on
title('Reduced Path Distance for corresponding generation')
xlabel('Generation No.')
ylabel('Total Path Distance')
min_globalplot              % Trend of minimums
gen_count                   % Generation at which new minimum is found




